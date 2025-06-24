import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';
import '../utils/colors.dart';

class NotificationCenter extends StatelessWidget {
  const NotificationCenter({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificações')),
      body: Consumer<NotificationService>(
        builder: (context, service, child) {
          final items = service.notifications;
          if (items.isEmpty) {
            return const Center(child: Text('Sem notificações'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final n = items[index];
              return ListTile(
                leading: Text(n.icon),
                title: Text(n.title),
                subtitle: Text(n.message),
                trailing: n.isRead
                    ? null
                    : const Icon(Icons.fiber_new, color: AppColors.primary),
                onTap: () => service.markAsRead(n.id),
              );
            },
          );
        },
      ),
    );
  }
}
