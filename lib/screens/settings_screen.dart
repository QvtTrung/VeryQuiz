import 'package:ct484_project/services/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ct484_project/providers/auth_manager.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool) changeThemeMode;

  const SettingsScreen({
    super.key,
    required this.changeThemeMode,
  });

  static const routeName = '/settings';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _soundVolume = 0.5;
  double _musicVolume = 0.5;

  @override
  void initState() {
    super.initState();
    // Lấy giá trị ban đầu từ AudioService
    _soundVolume = AudioService().soundVolume;
    _musicVolume = AudioService().musicVolume;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard if it's open
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          title: Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          centerTitle: true,
          elevation: 3,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _buildSettingOption(
                  context,
                  label: 'Sound',
                  widget: Slider(
                    value: _soundVolume,
                    min: 0,
                    max: 1,
                    onChanged: (value) {
                      setState(() {
                        _soundVolume = value;
                      });
                      AudioService().setSoundVolume(value);
                    },
                  ),
                ),
                _buildSettingOption(
                  context,
                  label: 'Music',
                  widget: Slider(
                    value: _musicVolume,
                    min: 0,
                    max: 1,
                    onChanged: (value) {
                      setState(() {
                        _musicVolume = value;
                      });
                      AudioService().setMusicVolume(value);
                    },
                  ),
                ),
                _buildSettingSwitch(
                  context,
                  label: 'Dark Mode',
                  value: isDarkMode,
                  onChanged: (newValue) {
                    widget.changeThemeMode(newValue);
                  },
                ),
                const SizedBox(
                  height: 30,
                ),
                _buildAuthButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingOption(BuildContext context,
      {required String label, required Widget widget}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        widget,
      ],
    );
  }

  Widget _buildSettingSwitch(BuildContext context,
      {required String label,
      required bool value,
      required ValueChanged<bool> onChanged}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: (newValue) {
            onChanged(newValue);
          },
          activeColor: Theme.of(context).colorScheme.onSurface,
          activeTrackColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          inactiveTrackColor:
              Theme.of(context).colorScheme.surfaceContainerHigh,
          inactiveThumbColor: Theme.of(context).disabledColor,
        ),
      ],
    );
  }

  Widget _buildAuthButton(BuildContext context) {
    return Consumer<AuthManager>(
      builder: (context, authManager, child) {
        return ElevatedButton(
          onPressed: () {
            if (authManager.isAuth) {
              // Hiển thị dialog xác nhận trước khi đăng xuất
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop(); // Đóng dialog
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop(); // Đóng dialog
                        authManager.logout(); // Thực hiện đăng xuất
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Signed out successfully!')),
                        );
                      },
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );
            } else {
              // Điều hướng đến AuthScreen khi chưa đăng nhập
              Navigator.of(context).pushNamed("/auth");
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            elevation: 2,
          ),
          child: Text(
            authManager.isAuth
                ? 'Signed in as ${authManager.user?.email ?? ''}'
                : 'Sign in to save your data',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }
}
