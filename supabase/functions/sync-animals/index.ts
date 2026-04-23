import "@supabase/functions-js/edge-runtime.d.ts";

import { createClient } from "npm:@supabase/supabase-js@2";

const MOA_API_URL =
  Deno.env.get("MOA_API_URL") ??
  "https://data.moa.gov.tw/Service/OpenData/TransService.aspx?UnitId=QcbUEzN6E6DL";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
const SYNC_SECRET = Deno.env.get("SYNC_SECRET");
const PAGE_SIZE = 1000;
const UPSERT_BATCH_SIZE = 200;
const INACTIVE_THRESHOLD = 2;

type MoaAnimal = {
  animal_id?: number | string | null;
  animal_subid?: string | null;
  animal_area_pkid?: number | string | null;
  animal_shelter_pkid?: number | string | null;
  animal_place?: string | null;
  animal_kind?: string | null;
  animal_Variety?: string | null;
  animal_sex?: string | null;
  animal_bodytype?: string | null;
  animal_colour?: string | null;
  animal_age?: string | null;
  animal_sterilization?: string | null;
  animal_bacterin?: string | null;
  animal_foundplace?: string | null;
  animal_title?: string | null;
  animal_status?: string | null;
  animal_remark?: string | null;
  animal_caption?: string | null;
  animal_opendate?: string | null;
  animal_closeddate?: string | null;
  animal_update?: string | null;
  animal_createtime?: string | null;
  shelter_name?: string | null;
  album_file?: string | null;
  album_update?: string | null;
  cDate?: string | null;
  shelter_address?: string | null;
  shelter_tel?: string | null;
  [key: string]: unknown;
};

type SyncRunRow = {
  id: string;
  sync_type: "full" | "incremental";
  status: "running" | "success" | "failed";
  started_at?: string;
  finished_at?: string;
  fetched_count?: number;
  upserted_count?: number;
  marked_inactive_count?: number;
  error_message?: string | null;
  metadata?: Record<string, unknown>;
};

type AnimalUpsertRow = Record<string, unknown>;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-sync-secret",
  "Content-Type": "application/json",
};

function jsonResponse(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: corsHeaders });
}

async function failSyncRun(
  supabase: ReturnType<typeof createClient> | null,
  runId: string | null,
  message: string,
) {
  if (supabase == null || runId == null) {
    return;
  }

  const { error } = await supabase
    .from("sync_runs")
    .update({
      status: "failed",
      finished_at: new Date().toISOString(),
      error_message: message,
    })
    .eq("id", runId);

  if (error) {
    console.error(`Failed to mark sync run as failed: ${error.message}`);
  }
}

function assertEnv(name: string, value: string | undefined): string {
  if (!value) {
    throw new Error(`Missing required environment variable: ${name}`);
  }
  return value;
}

function chunk<T>(items: T[], size: number): T[][] {
  const result: T[][] = [];
  for (let i = 0; i < items.length; i += size) {
    result.push(items.slice(i, i + size));
  }
  return result;
}

function asInt(value: unknown): number | null {
  if (value === null || value === undefined || value === "") {
    return null;
  }
  if (typeof value === "number" && Number.isFinite(value)) {
    return Math.trunc(value);
  }
  const parsed = Number.parseInt(String(value), 10);
  return Number.isNaN(parsed) ? null : parsed;
}

function asText(value: unknown): string | null {
  if (value === null || value === undefined) {
    return null;
  }
  const text = String(value).trim();
  return text.length > 0 ? text : null;
}

function asDate(value: unknown): string | null {
  const text = asText(value);
  if (!text) {
    return null;
  }

  const normalized = text.replaceAll("/", "-");
  const parsed = new Date(normalized);
  if (Number.isNaN(parsed.getTime())) {
    return null;
  }

  return parsed.toISOString().slice(0, 10);
}

function asTimestamp(value: unknown): string | null {
  const text = asText(value);
  if (!text) {
    return null;
  }

  const normalized = text.replaceAll("/", "-");
  const parsed = new Date(normalized);
  if (Number.isNaN(parsed.getTime())) {
    return null;
  }

  return parsed.toISOString();
}

function detectCity(animal: MoaAnimal): string | null {
  const source = [
    animal.shelter_address,
    animal.animal_place,
    animal.animal_foundplace,
  ]
    .map(asText)
    .filter(Boolean)
    .join(" ");

  if (!source) {
    return null;
  }

  const cityTokens = [
    "臺北市",
    "台北市",
    "新北市",
    "桃園市",
    "臺中市",
    "台中市",
    "臺南市",
    "台南市",
    "高雄市",
    "基隆市",
    "新竹市",
    "新竹縣",
    "苗栗縣",
    "彰化縣",
    "南投縣",
    "雲林縣",
    "嘉義市",
    "嘉義縣",
    "屏東縣",
    "宜蘭縣",
    "花蓮縣",
    "臺東縣",
    "台東縣",
    "澎湖縣",
    "金門縣",
    "連江縣",
  ];

  const matched = cityTokens.find((token) => source.includes(token));
  return matched ? matched.replaceAll("臺", "台") : null;
}

function mapAnimalRow(
  animal: MoaAnimal,
  syncRunId: string,
  seenAtIso: string,
): AnimalUpsertRow | null {
  const animalId = asInt(animal.animal_id);
  if (animalId === null) {
    return null;
  }

  return {
    animal_id: animalId,
    animal_subid: asText(animal.animal_subid),
    animal_area_pkid: asInt(animal.animal_area_pkid),
    animal_shelter_pkid: asInt(animal.animal_shelter_pkid),
    animal_place: asText(animal.animal_place),
    animal_kind: asText(animal.animal_kind),
    animal_variety: asText(animal.animal_Variety),
    animal_sex: asText(animal.animal_sex),
    animal_bodytype: asText(animal.animal_bodytype),
    animal_colour: asText(animal.animal_colour),
    animal_age: asText(animal.animal_age),
    animal_sterilization: asText(animal.animal_sterilization),
    animal_bacterin: asText(animal.animal_bacterin),
    animal_foundplace: asText(animal.animal_foundplace),
    animal_title: asText(animal.animal_title),
    animal_status: asText(animal.animal_status),
    animal_remark: asText(animal.animal_remark),
    animal_caption: asText(animal.animal_caption),
    animal_opendate: asDate(animal.animal_opendate),
    animal_closeddate: asDate(animal.animal_closeddate),
    animal_update: asTimestamp(animal.animal_update),
    animal_createtime: asTimestamp(animal.animal_createtime),
    shelter_name: asText(animal.shelter_name),
    album_file: asText(animal.album_file),
    album_update: asTimestamp(animal.album_update),
    c_date: asTimestamp(animal.cDate),
    shelter_address: asText(animal.shelter_address),
    shelter_tel: asText(animal.shelter_tel),
    city: detectCity(animal),
    is_active: true,
    raw_json: animal,
    last_seen_at: seenAtIso,
    last_synced_at: seenAtIso,
    sync_run_id: syncRunId,
    missing_runs_count: 0,
    updated_at: seenAtIso,
  };
}

async function fetchMoaPage(skip: number): Promise<MoaAnimal[]> {
  const url = new URL(MOA_API_URL);
  url.searchParams.set("\$top", String(PAGE_SIZE));
  url.searchParams.set("\$skip", String(skip));

  const response = await fetch(url.toString(), {
    headers: { Accept: "application/json" },
  });

  if (!response.ok) {
    throw new Error(`MOA API request failed with status ${response.status}`);
  }

  const data = await response.json();
  if (!Array.isArray(data)) {
    throw new Error("MOA API returned a non-array response");
  }

  return data as MoaAnimal[];
}

async function markMissingAnimals(
  supabase: ReturnType<typeof createClient>,
  syncRunId: string,
  seenAtIso: string,
) {
  let markedInactiveCount = 0;
  const { data, error } = await supabase
    .from("animals")
    .select("animal_id, missing_runs_count")
    .eq("is_active", true)
    .or(`sync_run_id.is.null,sync_run_id.neq.${syncRunId}`);

  if (error) {
    throw new Error(`Failed to load stale animals: ${error.message}`);
  }

  if (!data || data.length == 0) {
    return 0;
  }

  for (const row of data) {
    const nextMissingRuns = (row.missing_runs_count ?? 0) + 1;
    const shouldDeactivate = nextMissingRuns >= INACTIVE_THRESHOLD;
    if (shouldDeactivate) {
      markedInactiveCount += 1;
    }

    const { error: updateError } = await supabase
      .from("animals")
      .update({
        missing_runs_count: nextMissingRuns,
        is_active: shouldDeactivate ? false : true,
        updated_at: seenAtIso,
      })
      .eq("animal_id", row.animal_id);

    if (updateError) {
      throw new Error(
        `Failed to update missing animals: ${updateError.message}`,
      );
    }
  }

  return markedInactiveCount;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  let supabase: ReturnType<typeof createClient> | null = null;
  let runId: string | null = null;

  try {
    if (SYNC_SECRET) {
      const requestSecret = req.headers.get("x-sync-secret");
      if (requestSecret !== SYNC_SECRET) {
        return jsonResponse({ error: "Unauthorized" }, 401);
      }
    }

    const supabaseUrl = assertEnv("SUPABASE_URL", SUPABASE_URL);
    const serviceRoleKey = assertEnv(
      "SUPABASE_SERVICE_ROLE_KEY",
      SUPABASE_SERVICE_ROLE_KEY,
    );
    supabase = createClient(supabaseUrl, serviceRoleKey);
    runId = crypto.randomUUID();
    const seenAtIso = new Date().toISOString();

    let mode: "full" | "incremental" = "full";
    if (req.method !== "GET") {
      try {
        const body = await req.json();
        if (body && body.mode === "incremental") {
          mode = "incremental";
        }
      } catch {
        // Empty body should still allow default full sync.
      }
    }

    const initialRun: SyncRunRow = {
      id: runId,
      sync_type: mode,
      status: "running",
      started_at: seenAtIso,
      metadata: {
        source: "moa_animals",
        page_size: PAGE_SIZE,
      },
    };

    const { error: runInsertError } = await supabase
      .from("sync_runs")
      .insert(initialRun);

    if (runInsertError) {
      throw new Error(
        `Failed to create sync_runs row: ${runInsertError.message}`,
      );
    }

    let skip = 0;
    let fetchedCount = 0;
    let upsertedCount = 0;

    while (true) {
      const page = await fetchMoaPage(skip);
      fetchedCount += page.length;

      const rows = page
        .map((animal) => mapAnimalRow(animal, runId, seenAtIso))
        .filter((row): row is AnimalUpsertRow => row !== null);

      for (const batch of chunk(rows, UPSERT_BATCH_SIZE)) {
        const { error: upsertError } = await supabase
          .from("animals")
          .upsert(batch, { onConflict: "animal_id" });

        if (upsertError) {
          throw new Error(`Failed to upsert animals: ${upsertError.message}`);
        }

        upsertedCount += batch.length;
      }

      if (page.length < PAGE_SIZE) {
        break;
      }

      skip += PAGE_SIZE;
    }

    const markedInactiveCount = await markMissingAnimals(
      supabase,
      runId,
      seenAtIso,
    );

    const { error: runUpdateError } = await supabase
      .from("sync_runs")
      .update({
        status: "success",
        finished_at: new Date().toISOString(),
        fetched_count: fetchedCount,
        upserted_count: upsertedCount,
        marked_inactive_count: markedInactiveCount,
        error_message: null,
      })
      .eq("id", runId);

    if (runUpdateError) {
      throw new Error(
        `Failed to finalize sync_runs row: ${runUpdateError.message}`,
      );
    }

    return jsonResponse({
      ok: true,
      run_id: runId,
      mode,
      fetched_count: fetchedCount,
      upserted_count: upsertedCount,
      marked_inactive_count: markedInactiveCount,
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error";
    console.error(message);
    await failSyncRun(supabase, runId, message);
    return jsonResponse({ ok: false, error: message }, 500);
  }
});
