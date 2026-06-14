import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/notification.dart';
import '../../services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  NotificationCategory _selectedCategory = NotificationCategory.all;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<NotificationService>();
    final notifications = service.notifications;
    final totalCount = notifications.length;
    final unreadCount = service.unreadCount;
    final urgentCount = notifications.where((n) => n.category == NotificationCategory.urgent && !n.isRead).length;

    // Filter by category
    List<AppNotification> filteredList = notifications;
    if (_selectedCategory != NotificationCategory.all) {
      filteredList = filteredList.where((n) => n.category == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filteredList = filteredList.where((n) =>
          n.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          n.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          n.senderName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF0B1C30),
          ),
        ),
        centerTitle: true,
        actions: [
          if (service.unreadCount > 0)
            TextButton.icon(
              onPressed: () {
                service.markAllAsRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Marked all as read'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.done_all, size: 18),
              label: const Text('Read all'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF3525CD),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search notifications...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF3525CD)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // Lumina Briefing Card (Creative Element)
          NotificationBriefCard(
            totalCount: totalCount,
            unreadCount: unreadCount,
            urgentCount: urgentCount,
          ),

          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: NotificationCategory.values.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(
                      _getCategoryName(cat),
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF5A5F68),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF3525CD),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF3525CD) : Colors.grey.shade200,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Notification List
          Expanded(
            child: filteredList.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      return _buildNotificationCard(context, service, item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF3525CD).withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_outlined,
              size: 72,
              color: Color(0xFF3525CD),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0B1C30),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'No matching results found for "$_searchQuery"'
                : 'We will notify you when there is something new.',
            style: const TextStyle(
              color: Color(0xFF5A5F68),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
      BuildContext context, NotificationService service, AppNotification item) {
    final categoryColor = _getCategoryColor(item.category);
    final formattedTime = _formatTimestamp(item.timestamp);

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) {
        service.deleteNotification(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification deleted'),
            action: SnackBarAction(
              label: 'Undo',
              textColor: Colors.yellow,
              onPressed: () {
                // Undo action can be wired if local restore is supported
              },
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: item.isRead ? 0 : 3,
        shadowColor: const Color(0xFF3525CD).withOpacity(0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: item.isRead ? Colors.grey.shade100 : const Color(0xFF3525CD).withOpacity(0.1),
            width: 1.5,
          ),
        ),
        color: item.isRead ? Colors.white : const Color(0xFFECEBFF).withOpacity(0.4),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            service.markAsRead(item.id);
            _showNotificationDetail(context, service, item);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sender Avatar or Category Icon
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: categoryColor.withOpacity(0.1),
                      child: Text(
                        item.senderName.isNotEmpty ? item.senderName[0].toUpperCase() : 'H',
                        style: TextStyle(
                          color: categoryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    if (!item.isRead)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3525CD),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),

                // Details
                Expanded(
                  child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Container(
                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                             decoration: BoxDecoration(
                               color: categoryColor.withOpacity(0.1),
                               borderRadius: BorderRadius.circular(12),
                             ),
                             child: Text(
                               _getCategoryName(item.category).toUpperCase(),
                               style: TextStyle(
                                 fontSize: 10,
                                 fontWeight: FontWeight.bold,
                                 color: categoryColor,
                               ),
                             ),
                           ),
                           Text(
                             formattedTime,
                             style: TextStyle(
                               fontSize: 12,
                               color: Colors.grey.shade500,
                             ),
                           ),
                         ],
                       ),
                       const SizedBox(height: 8),
                       Text(
                         item.title,
                         style: TextStyle(
                           fontSize: 15,
                           fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                           color: const Color(0xFF0B1C30),
                         ),
                       ),
                       const SizedBox(height: 4),
                       Text(
                         item.content,
                         maxLines: 2,
                         overflow: TextOverflow.ellipsis,
                         style: TextStyle(
                           fontSize: 13,
                           color: Colors.grey.shade600,
                           height: 1.4,
                         ),
                       ),
                       if (item.actionLabel != null) ...[
                         const SizedBox(height: 8),
                         Text(
                           item.actionLabel!,
                           style: const TextStyle(
                             fontSize: 13,
                             fontWeight: FontWeight.bold,
                             color: Color(0xFF3525CD),
                           ),
                         ),
                       ],
                     ],
                   ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationDetail(
      BuildContext context, NotificationService service, AppNotification item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final categoryColor = _getCategoryColor(item.category);
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getCategoryName(item.category).toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('HH:mm - dd/MM/yyyy').format(item.timestamp),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B1C30),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sent by: ${item.senderName}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const Divider(height: 32),
              Text(
                item.content,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF5A5F68),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        service.deleteNotification(item.id);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete Notification'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade400,
                        side: BorderSide(color: Colors.red.shade200),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3525CD),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  String _getCategoryName(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.all:
        return 'All';
      case NotificationCategory.urgent:
        return 'Urgent';
      case NotificationCategory.system:
        return 'System';
      case NotificationCategory.task:
        return 'Task';
      case NotificationCategory.news:
        return 'News';
    }
  }

  Color _getCategoryColor(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.urgent:
        return Colors.redAccent.shade400;
      case NotificationCategory.system:
        return Colors.blue.shade600;
      case NotificationCategory.task:
        return Colors.orange.shade700;
      case NotificationCategory.news:
        return const Color(0xFF3525CD);
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('dd/MM').format(dt);
    }
  }
}

class NotificationBriefCard extends StatelessWidget {
  final int totalCount;
  final int unreadCount;
  final int urgentCount;

  const NotificationBriefCard({
    super.key,
    required this.totalCount,
    required this.unreadCount,
    required this.urgentCount,
  });

  @override
  Widget build(BuildContext context) {
    String title = "Good day!";
    String message = "You're all caught up. No unread notifications.";

    if (unreadCount > 0) {
      title = "Inbox Review";
      if (urgentCount > 0) {
        message = "You have $unreadCount unread notifications, including $urgentCount urgent updates.";
      } else {
        message = "You have $unreadCount unread notifications waiting for your review.";
      }
    }

    final readPercent = totalCount == 0 ? 1.0 : (totalCount - unreadCount) / totalCount;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff4B46E5),
            Color(0xff6C63FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff4B46E5).withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.amberAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Lumina Briefing',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: readPercent,
                  backgroundColor: Colors.white.withOpacity(0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 4.5,
                ),
              ),
              Text(
                "${(readPercent * 100).round()}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
