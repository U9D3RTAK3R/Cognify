import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class CardDeck extends StatefulWidget {
  final List<String> options;
  final Function(int) onSelect;
  final int? selectedIndex;
  final int? correctIndex;
  final bool showResult;

  const CardDeck({
    super.key,
    required this.options,
    required this.onSelect,
    this.selectedIndex,
    this.correctIndex,
    this.showResult = false,
  });

  @override
  State<CardDeck> createState() => _CardDeckState();
}

class _CardDeckState extends State<CardDeck> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final cardCount = widget.options.length;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive card dimensions
    final cardWidth = (screenWidth / cardCount).clamp(80.0, 110.0);
    final cardHeight = cardWidth * 1.35;
    final fanAngle = 6.0;
    final overlapOffset = cardWidth * 0.35;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxHeight,
          width: screenWidth,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: List.generate(cardCount, (index) {
              final isHovered = _hoveredIndex == index;
              final isSelected = widget.selectedIndex == index;
              final isCorrect =
                  widget.showResult && index == widget.correctIndex;
              final isWrong =
                  widget.showResult &&
                  isSelected &&
                  index != widget.correctIndex;

              // Calculate position and rotation
              final middleIndex = (cardCount - 1) / 2;
              final offsetFromCenter = index - middleIndex;
              final rotation = offsetFromCenter * fanAngle * (3.14159 / 180);
              final xOffset = offsetFromCenter * (cardWidth - overlapOffset);

              // Colors based on state
              Color borderColor = Colors.white.withOpacity(0.3);
              Color bgColor = AppTheme.cardColor;
              List<BoxShadow> shadows = [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ];

              if (isHovered && !widget.showResult) {
                borderColor = AppTheme.primaryCyan;
                bgColor = AppTheme.primaryCyan.withOpacity(0.15);
                shadows = [
                  BoxShadow(
                    color: AppTheme.primaryCyan.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ];
              }
              if (isSelected && !widget.showResult) {
                borderColor = AppTheme.primaryCyan;
                bgColor = AppTheme.primaryCyan.withOpacity(0.2);
              }
              if (isCorrect) {
                borderColor = Colors.green;
                bgColor = Colors.green.withOpacity(0.2);
                shadows = [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.6),
                    blurRadius: 20,
                    spreadRadius: 3,
                  ),
                ];
              }
              if (isWrong) {
                borderColor = Colors.red;
                bgColor = Colors.red.withOpacity(0.2);
                shadows = [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.6),
                    blurRadius: 20,
                    spreadRadius: 3,
                  ),
                ];
              }

              final centerX = (screenWidth / 2) - (cardWidth / 2) + xOffset;
              final topOffset = isHovered ? 5.0 : 25.0;

              return Positioned(
                left: centerX,
                top: topOffset,
                child:
                    GestureDetector(
                          onTap: widget.showResult
                              ? null
                              : () => widget.onSelect(index),
                          child: MouseRegion(
                            onEnter: (_) =>
                                setState(() => _hoveredIndex = index),
                            onExit: (_) => setState(() => _hoveredIndex = null),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutBack,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateZ(isHovered ? 0 : rotation)
                                ..scale(isHovered ? 1.08 : 1.0),
                              transformAlignment: Alignment.bottomCenter,
                              width: cardWidth,
                              height: cardHeight,
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: borderColor,
                                  width: isHovered || isSelected ? 2.5 : 1.5,
                                ),
                                boxShadow: shadows,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  children: [
                                    // Letter badge
                                    Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isHovered
                                            ? AppTheme.primaryCyan
                                            : Colors.white.withOpacity(0.15),
                                      ),
                                      child: Center(
                                        child: Text(
                                          String.fromCharCode(65 + index),
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: isHovered
                                                ? Colors.black
                                                : Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Option text
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          widget.options[index],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: isHovered ? 12 : 11,
                                            color: isHovered
                                                ? AppTheme.primaryCyan
                                                : Colors.white,
                                            fontWeight: isHovered
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    // Result icon
                                    if (isCorrect)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 20,
                                      )
                                    else if (isWrong)
                                      const Icon(
                                        Icons.cancel,
                                        color: Colors.red,
                                        size: 20,
                                      ).animate().shake(
                                        hz: 4,
                                        duration: 400.ms,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: (index * 60).ms, duration: 250.ms)
                        .slideY(
                          begin: 0.4,
                          end: 0,
                          delay: (index * 60).ms,
                          duration: 350.ms,
                          curve: Curves.easeOutBack,
                        ),
              );
            }),
          ),
        );
      },
    );
  }
}
