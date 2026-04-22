import 'package:flutter/material.dart';

import '../models/animal.dart';

class AnimalCard extends StatelessWidget {
  const AnimalCard({super.key, required this.animal});

  final Animal animal;

  @override
  Widget build(BuildContext context) {
    final bool isMale = animal.sexText == '公';
    final Color badgeColor = isMale
        ? Colors.blue.shade100
        : Colors.pink.shade100;
    final Color genderColor = isMale
        ? Colors.blue.shade700
        : Colors.pink.shade700;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: animal.hasImage
                  ? Image.network(
                      animal.albumFile!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) =>
                          const _AnimalImageFallback(),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return const _AnimalImageFallback();
                      },
                    )
                  : const _AnimalImageFallback(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        animal.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        animal.sexText,
                        style: TextStyle(
                          color: genderColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${animal.categoryLabel}・${animal.ageText}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 2),
                Text(
                  animal.primaryLocation,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimalImageFallback extends StatelessWidget {
  const _AnimalImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0E8DE),
      alignment: Alignment.center,
      child: const Icon(Icons.pets_rounded, size: 44, color: Color(0xFF9B8068)),
    );
  }
}
