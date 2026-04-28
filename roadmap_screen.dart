import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/models/milestone.dart';
import '../../../../core/services/app_prefs.dart';
import '../../../../core/presentation/widgets/aesthetic_background.dart';
import 'milestone_screen.dart';
import '../../../../core/providers/user_provider.dart';

class RoadmapScreen extends ConsumerStatefulWidget {
  final String goal;
  final String skill;
  final List<Milestone> milestones;

  const RoadmapScreen({
    super.key,
    required this.goal,
    required this.skill,
    required this.milestones,
  });

  @override
  ConsumerState<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends ConsumerState<RoadmapScreen> {
  void _onScoreUpdated() {
    setState(() {
      AppPrefs.save(widget.goal, widget.skill, widget.milestones);
    });
    // Invalidate profile milestones to ensure sync
    ref.invalidate(userMilestonesProvider);
  }


  void _openMilestone(Milestone m) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MilestoneScreen(
          milestone: m,
          skill: widget.skill,
          onScoreUpdated: _onScoreUpdated,
        ),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AestheticBackground(
        child: Stack(
          children: [
            SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildPremiumProgressCard(),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final milestone = widget.milestones[index];
                          final isCompleted = milestone.completed;
                          final isLocked = index > 0 && !widget.milestones[index - 1].completed;
                          final isCurrent = !isCompleted && !isLocked;

                          return _RoadmapNode(
                            index: index,
                            milestone: milestone,
                            isLast: index == widget.milestones.length - 1,
                            isCompleted: isCompleted,
                            isCurrent: isCurrent,
                            isLocked: isLocked,
                            onTap: () => _openMilestone(milestone),
                          );
                        },
                        childCount: widget.milestones.length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
            ),

            // Back Button
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 20,
              child: _buildBackButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumProgressCard() {
    final completedCount = widget.milestones.where((m) => m.completed).length;
    final total = widget.milestones.length;
    final progress = total > 0 ? (completedCount / total) : 0.0;
    final percentage = (progress * 100).toInt();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 80, 24, 0),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF0F172A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withAlpha(76), // 0.3 opacity
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overall Progress',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withAlpha(178), // 0.7 opacity
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$percentage',
                            style: GoogleFonts.orbitron(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6.0, left: 4),
                            child: Text(
                              '%',
                              style: GoogleFonts.orbitron(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(38), // 0.15 opacity
                      shape: BoxShape.circle,
                    ),
                    child: Icon(PhosphorIcons.trendUp(PhosphorIconsStyle.bold), color: Colors.white, size: 32),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    Container(height: 8, color: Colors.white.withAlpha(51)), // 0.2 opacity
                    FractionallySizedBox(
                      widthFactor: progress.clamp(0.01, 1.0),
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(color: Colors.white.withAlpha(102), blurRadius: 10), // 0.4 opacity
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '$completedCount of $total skills completed',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white.withAlpha(204), // 0.8 opacity
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25), // 0.1 opacity
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(PhosphorIcons.caretLeft(), color: const Color(0xFF1E293B)),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/new-skill');
          }
        },
      ),
    );
  }
}


class _RoadmapNode extends StatelessWidget {
  final int index;
  final Milestone milestone;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLocked;
  final bool isLast;
  final VoidCallback onTap;

  const _RoadmapNode({
    required this.index,
    required this.milestone,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLocked,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double horizontalOffset = math.sin(index * 0.82) * 100;
    // Next node's offset for the path drawing
    final double nextOffset = math.sin((index + 1) * 0.82) * 100;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Path segment to the next node
        if (!isLast)
          Positioned(
            top: 60, // Start from middle of node
            left: 0,
            right: 0,
            child: Center(
              child: CustomPaint(
                size: const Size(double.infinity, 160), 
                painter: _ConnectorPainter(
                  startOffset: horizontalOffset,
                  endOffset: nextOffset,
                  isLocked: isLocked || (index + 1 > 0 && !milestone.completed), 
                ),
              ),
            ),
          ),

        // The Node Content
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Transform.translate(
            offset: Offset(horizontalOffset, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: isLocked ? null : onTap,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isCurrent)
                        const _PulseCircle(),
                      
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isLocked 
                                ? [const Color(0xFFE2E8F0), const Color(0xFFCBD5E1)]
                                : isCompleted 
                                    ? [const Color(0xFFFACC15), const Color(0xFFEAB308)]
                                    : [const Color(0xFF3B82F6), const Color(0xFF0F172A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _getNodeColor().withAlpha(102), // 0.4 opacity
                              blurRadius: 25,
                              spreadRadius: 2,
                              offset: const Offset(0, 10),
                            ),
                            if (!isLocked) 
                              BoxShadow(
                                color: Colors.white.withAlpha(128), // 0.5 opacity
                                blurRadius: 10,
                                offset: const Offset(-4, -4),
                                spreadRadius: -2,
                              ),
                          ],
                          border: Border.all(
                            color: isLocked ? Colors.transparent : Colors.white.withAlpha(230), // 0.9 opacity
                            width: 6,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getIcon(),
                                color: isLocked ? const Color(0xFF94A3B8) : Colors.white,
                                size: 30,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${index + 1}',
                                style: GoogleFonts.orbitron(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: isLocked ? const Color(0xFF94A3B8) : Colors.white.withAlpha(230), // 0.9 opacity
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      if (isCompleted)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.check, color: Colors.white, size: 14),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(204), // 0.8 opacity
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SizedBox(
                    width: 130,
                    child: Text(
                      milestone.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.orbitron(
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                        fontSize: 11,
                        color: isLocked ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getNodeColor() {
    if (isCompleted) return const Color(0xFFFACC15); // Golden for completed
    if (isCurrent) return const Color(0xFF3B82F6); // Blue for current
    return const Color(0xFFE2E8F0); // Gray for locked
  }

  IconData _getIcon() {
    if (isLocked) return PhosphorIcons.lockSimple(PhosphorIconsStyle.fill);
    if (isCompleted) return PhosphorIcons.trophy(PhosphorIconsStyle.fill);
    return PhosphorIcons.rocketLaunch(PhosphorIconsStyle.fill);
  }
}

class _PulseCircle extends StatefulWidget {
  const _PulseCircle();

  @override
  State<_PulseCircle> createState() => _PulseCircleState();
}

class _PulseCircleState extends State<_PulseCircle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 80 + (20 * _controller.value),
          height: 80 + (20 * _controller.value),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF3B82F6).withAlpha((255 * (1 - _controller.value)).toInt()),
              width: 2,
            ),
          ),
        );
      },
    );
  }
}


class _ConnectorPainter extends CustomPainter {
  final double startOffset;
  final double endOffset;
  final bool isLocked;

  _ConnectorPainter({
    required this.startOffset,
    required this.endOffset,
    required this.isLocked,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: isLocked 
            ? [const Color(0xFFCBD5E1), const Color(0xFF94A3B8)]
            : [const Color(0xFF3B82F6), const Color(0xFF0F172A)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    final double startX = size.width / 2 + startOffset;
    final double endX = size.width / 2 + endOffset;
    final double startY = 30; 
    final double endY = 160;   

    path.moveTo(startX, startY);
    
    path.cubicTo(
      startX, startY + (endY - startY) * 0.4,
      endX, startY + (endY - startY) * 0.6,
      endX, endY,
    );

    canvas.drawPath(path, paint);
    
    final highlightPaint = Paint()
      ..color = Colors.white.withAlpha(51) // 0.2 opacity
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
      
    canvas.drawPath(path, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PathPainter extends CustomPainter {
  final int itemCount;
  _PathPainter({required this.itemCount});

  @override
  void paint(Canvas canvas, Size size) {
    // This painter was replaced by _ConnectorPainter which is segmented
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
