import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';

class ProfileForm extends StatefulWidget {
  const ProfileForm({super.key});

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController =
  TextEditingController();

  final TextEditingController _workplaceController =
  TextEditingController();

  int _sleepHours = 8;
  TimeOfDay _bedtime = const TimeOfDay(
    hour: 23,
    minute: 0,
  );

  bool _initialized = false;


  @override
  void dispose() {
    _nameController.dispose();
    _workplaceController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;

    final service = context.read<AuthService>();

    _nameController.text =
        service.profile?.fullName ?? '';

    _workplaceController.text =
        service.profile?.workplace ?? '';

    _sleepHours =
        service.profile?.sleepHours.inHours ?? 8;

    print(_sleepHours);
    _bedtime = service.profile?.bedtime ??
        const TimeOfDay(
          hour: 23,
          minute: 0,
        );

    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AuthService>();

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _workplaceController,
              decoration: const InputDecoration(
                labelText: 'Workplace',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            DropdownButtonFormField<int>(
              initialValue: _sleepHours,
              decoration: const InputDecoration(
                labelText: 'Sleep Duration',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 4,
                  child: Text('4 Hours'),
                ),
                DropdownMenuItem(
                  value: 5,
                  child: Text('5 Hours'),
                ),
                DropdownMenuItem(
                  value: 6,
                  child: Text('6 Hours'),
                ),
                DropdownMenuItem(
                  value: 7,
                  child: Text('7 Hours'),
                ),
                DropdownMenuItem(
                  value: 8,
                  child: Text('8 Hours'),
                ),
                DropdownMenuItem(
                  value: 9,
                  child: Text('9 Hours'),
                ),
                DropdownMenuItem(
                  value: 10,
                  child: Text('10 Hours'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _sleepHours = value ?? 8;
                });
              },
            ),

            const SizedBox(height: 24),

            Card(
              child: ListTile(
                leading: const Icon(Icons.bedtime),
                title: const Text('Bedtime'),
                subtitle: Text(
                  _bedtime.format(context),
                ),
                trailing: const Icon(Icons.edit),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _bedtime,
                  );

                  if (time != null) {
                    setState(() {
                      _bedtime = time;
                    });
                  }
                },
              ),
            ),

            const SizedBox(height: 24),



            FilledButton(
              onPressed: service.isLoading
                  ? null
                  : () async {
                if (!_formKey.currentState!
                    .validate()) {
                  return;
                }

                await service.updateProfile(
                  fullName:
                  _nameController.text.trim(),
                  workplace:
                  _workplaceController.text.trim(),
                  sleepHours: _sleepHours,
                  bedtime:
                  '${_bedtime.hour.toString().padLeft(2, '0')}:${_bedtime.minute.toString().padLeft(2, '0')}',
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Profile updated',
                      ),
                    ),
                  );
                }
              },
              child: service.isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child:
                CircularProgressIndicator(),
              )
                  : const Text(
                'Save Changes',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
