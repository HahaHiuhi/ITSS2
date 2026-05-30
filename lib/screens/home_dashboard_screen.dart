import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import '../models/task.dart';
import '../models/schedule.dart';
import 'task_detail_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final supabaseService = Provider.of<SupabaseService>(context);

    // Calculate progress
    final completedCount =
        supabaseService.tasks.where((t) => t.isCompleted).length;
    final totalCount = supabaseService.tasks.length;
    final double completionRate =
        totalCount > 0 ? completedCount / totalCount : 0.0;

    // Get today's classes
    final todayDay = DateTime.now().weekday; // 1 = Mon, 7 = Sun
    final todayClasses = supabaseService.schedules
        .where((s) => s.dayOfWeek == todayDay)
        .toList();

    // Get active tasks (up to 3)
    final upcomingDeadlines =
        supabaseService.tasks.where((t) => !t.isCompleted).take(3).toList();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(
                Icons.school_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Planner',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => supabaseService.signOut(),
            icon: const Icon(Icons.logout_rounded),
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await supabaseService.fetchSubjects();
          await supabaseService.fetchTasks();
          await supabaseService.fetchSchedules();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, Alex',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          totalCount > 0
                              ? 'You have ${totalCount - completedCount} tasks pending. Stay focused!'
                              : 'No tasks for today. Enjoy your day!',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('EEEE, MMM d').format(DateTime.now()),
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Bento Grid Circular Progress & Quick Stats
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Circular Card
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.02),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Progress',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 110,
                                  height: 110,
                                  child: CircularProgressIndicator(
                                    value: completionRate,
                                    strokeWidth: 10,
                                    backgroundColor:
                                        theme.colorScheme.surfaceContainer,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.colorScheme.primaryContainer,
                                    ),
                                    strokeCap: StrokeCap.round,
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${(completionRate * 100).toInt()}%',
                                      style: theme.textTheme.headlineMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      '$completedCount/$totalCount Done',
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              completionRate >= 1.0
                                  ? 'Fantastic! You finished all!'
                                  : 'Keep going, you\'re doing great!',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Quick Summary Card
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        _buildStatBox(
                          theme,
                          title: 'Schedules',
                          value: '${todayClasses.length}',
                          subtitle: 'Classes Today',
                          icon: Icons.school_outlined,
                          color: const Color(0xFF10B981),
                        ),
                        const SizedBox(height: 16),
                        _buildStatBox(
                          theme,
                          title: 'Pending',
                          value: '${totalCount - completedCount}',
                          subtitle: 'Tasks Left',
                          icon: Icons.hourglass_empty_rounded,
                          color: const Color(0xFFEF4444),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Today's Schedule Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today\'s Schedule',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'View Full',
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Horizontal Classes timetables
              SizedBox(
                height: 130,
                child: todayClasses.isEmpty
                    ? _buildEmptySchedulePlaceholder(theme)
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: todayClasses.length,
                        itemBuilder: (context, index) {
                          final schedule = todayClasses[index];
                          final subjectColor =
                              _parseColor(schedule.subject?.color);
                          return Container(
                            width: 200,
                            margin: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                            child: ContainerWithLeftBorder(
                              color: subjectColor,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${DateFormat('HH:mm').format(schedule.startTime)} - ${DateFormat('HH:mm').format(schedule.endTime)}',
                                      style:
                                          theme.textTheme.labelMedium?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      schedule.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          size: 14,
                                          color: theme.colorScheme.secondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            schedule.location ?? 'Online / Lab',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color:
                                                  theme.colorScheme.secondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 32),

              // Upcoming Deadlines Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upcoming Deadlines',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (upcomingDeadlines.length > 2)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${upcomingDeadlines.length} Upcoming',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Deadlines List
              upcomingDeadlines.isEmpty
                  ? _buildEmptyTasksPlaceholder(theme)
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: upcomingDeadlines.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final task = upcomingDeadlines[index];
                        final subColor = _parseColor(task.subject?.color);
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TaskDetailScreen(task: task),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: theme.colorScheme.outlineVariant
                                      .withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: task.isCompleted,
                                  onChanged: (val) {
                                    if (val != null) {
                                      supabaseService.toggleTaskCompletion(
                                          task.id, val);
                                    }
                                  },
                                  activeColor: theme.colorScheme.primary,
                                  shape: const CircleBorder(),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task.title,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          if (task.subject != null) ...[
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color:
                                                    subColor.withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                task.subject!.name,
                                                style: theme
                                                    .textTheme.labelSmall
                                                    ?.copyWith(
                                                  color: subColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                          Icon(
                                            Icons.event_outlined,
                                            size: 14,
                                            color: theme.colorScheme.secondary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            task.deadline != null
                                                ? DateFormat('MMM d, hh:mm a')
                                                    .format(task.deadline!)
                                                : 'No due date',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color:
                                                  theme.colorScheme.secondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: theme.colorScheme.secondary,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TaskDetailScreen()),
          );
        },
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildStatBox(
    ThemeData theme, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmptySchedulePlaceholder(ThemeData theme) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            color: theme.colorScheme.secondary.withValues(alpha: 0.3),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'No classes scheduled for today',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.secondary,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyTasksPlaceholder(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.playlist_add_check_rounded,
            color: theme.colorScheme.secondary.withValues(alpha: 0.3),
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Hurrah! No pending deadlines.',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Click the + button to add tasks.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.secondary,
            ),
          )
        ],
      ),
    );
  }

  Color _parseColor(String? colorHex) {
    if (colorHex == null) return const Color(0xFF3525CD);
    final buffer = StringBuffer();
    if (colorHex.length == 6 || colorHex.length == 7) buffer.write('ff');
    buffer.write(colorHex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

// Custom decoration for card borders
extension BorderDecoration on BoxDecoration {
  static BoxDecoration leftHandSideBorder({
    required Color color,
    required Color bg,
  }) {
    return BoxDecoration(
      color: bg,
      border: Border(
        left: BorderSide(color: color, width: 4),
        top: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        right: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
    );
  }
}

// Helper container with left-hand side colored bar
class ContainerWithLeftBorder extends StatelessWidget {
  final Color color;
  final Widget child;
  const ContainerWithLeftBorder({
    super.key,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 130,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
