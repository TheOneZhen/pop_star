import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/storage_service.dart';

/// 设置页：音效与震动开关，读写 StorageService。
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final StorageService _storage = StorageService();

  bool _loading = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final bool sound = await _storage.getSoundEnabled();
    final bool vibration = await _storage.getVibrationEnabled();
    if (!mounted) {
      return;
    }
    setState(() {
      _soundEnabled = sound;
      _vibrationEnabled = vibration;
      _loading = false;
    });
  }

  Future<void> _onSoundChanged(bool value) async {
    await _storage.setSoundEnabled(value);
    if (!mounted) {
      return;
    }
    setState(() {
      _soundEnabled = value;
    });
  }

  Future<void> _onVibrationChanged(bool value) async {
    await _storage.setVibrationEnabled(value);
    if (!mounted) {
      return;
    }
    setState(() {
      _vibrationEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A237E), Color(0xFF311B92)],
          ),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  SwitchListTile(
                    title: const Text('音效', style: TextStyle(color: Colors.white)),
                    subtitle: const Text(
                      '消除与游戏结束音效',
                      style: TextStyle(color: Colors.white54),
                    ),
                    value: _soundEnabled,
                    onChanged: _onSoundChanged,
                  ),
                  SwitchListTile(
                    title: const Text('震动', style: TextStyle(color: Colors.white)),
                    subtitle: const Text(
                      '消除时触觉反馈',
                      style: TextStyle(color: Colors.white54),
                    ),
                    value: _vibrationEnabled,
                    onChanged: _onVibrationChanged,
                  ),
                ],
              ),
      ),
    );
  }
}
