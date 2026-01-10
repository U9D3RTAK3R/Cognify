import 'package:flutter/material.dart';

class BossHpBar extends StatelessWidget {
  final int currentHp;
  final int maxHp;

  const BossHpBar({super.key, required this.currentHp, required this.maxHp});

  @override
  Widget build(BuildContext context) {
    final hpPct = currentHp / maxHp;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "BOSS HP",
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "$currentHp / $maxHp",
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 20,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: MediaQuery.of(context).size.width * hpPct * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: hpPct > 0.5
                        ? [Colors.green, Colors.lightGreen]
                        : [Colors.red, Colors.orange],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (hpPct > 0.5 ? Colors.green : Colors.red)
                          .withOpacity(0.6),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
