import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/tajweed_model.dart';

class RuleDetailView extends StatelessWidget {
  final TajweedModel rule;

  const RuleDetailView({super.key, required this.rule});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(rule.title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Content Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    rule.content,
                    style: const TextStyle(fontSize: 18, height: 1.6),
                    textAlign: TextAlign.justify,
                  ),
                ),

                const SizedBox(height: 24),

                // Examples Section
                if (rule.examplesList.isNotEmpty) ...[
                  Text(
                    'examples'.tr,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...rule.examplesList.map(
                    (example) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.primaryColor.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.play_circle_outline,
                            color: theme.primaryColor,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              example,
                              style: const TextStyle(
                                fontSize: 22,
                                fontFamily: 'Amiri', // Or your quran font
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  if (rule.examplesList.isNotEmpty)
                    Center(
                      child: Text(
                        'tap_to_listen_hint'.tr,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
