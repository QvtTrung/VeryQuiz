// lib/services/audio_service.dart
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  AudioPlayer? _musicPlayer;
  AudioPlayer? _soundPlayer; // Dùng cho correct/wrong answer
  AudioPlayer? _quizCompletePlayer; // Dùng riêng cho quiz complete
  double _musicVolume = 0.5;
  double _soundVolume = 0.5;
  bool _isMusicEnabled = true;
  bool _isSoundEnabled = true;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _musicVolume = prefs.getDouble('music_volume') ?? 0.5;
    _soundVolume = prefs.getDouble('sound_volume') ?? 0.5;
    _isMusicEnabled = prefs.getBool('music_enabled') ?? true;
    _isSoundEnabled = prefs.getBool('sound_enabled') ?? true;

    _ensurePlayersInitialized();
    await _musicPlayer!.setVolume(_musicVolume);
    await _soundPlayer!.setVolume(_soundVolume);
    await _quizCompletePlayer!.setVolume(_soundVolume);
  }

  void _ensurePlayersInitialized() {
    _musicPlayer ??= AudioPlayer();
    _soundPlayer ??= AudioPlayer();
    _quizCompletePlayer ??= AudioPlayer();
  }

  double get musicVolume => _musicVolume;
  double get soundVolume => _soundVolume;
  bool get isMusicEnabled => _isMusicEnabled;
  bool get isSoundEnabled => _isSoundEnabled;

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('music_volume', _musicVolume);
    await prefs.setDouble('sound_volume', _soundVolume);
    await prefs.setBool('music_enabled', _isMusicEnabled);
    await prefs.setBool('sound_enabled', _isSoundEnabled);
  }

  Future<void> setMusicEnabled(bool enabled) async {
    _isMusicEnabled = enabled;
    if (!enabled) {
      await _musicPlayer?.stop();
    } else if (_musicPlayer?.playing == false) {
      await playMusic();
    }
    await _saveSettings();
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _isSoundEnabled = enabled;
    if (!enabled) {
      await _soundPlayer?.stop();
      await _quizCompletePlayer?.stop();
    }
    await _saveSettings();
  }

  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume;
    _ensurePlayersInitialized();
    await _musicPlayer!.setVolume(volume);
    await _saveSettings();
  }

  Future<void> setSoundVolume(double volume) async {
    _soundVolume = volume;
    _ensurePlayersInitialized();
    await _soundPlayer!.setVolume(volume);
    await _quizCompletePlayer!.setVolume(volume);
    await _saveSettings();
  }

  Future<void> playMusic() async {
    if (!_isMusicEnabled) return;
    _ensurePlayersInitialized();
    await _musicPlayer!.setAudioSource(
      AudioSource.asset('assets/audio/background_music.mp3'),
    );
    await _musicPlayer!.setVolume(_musicVolume);
    await _musicPlayer!.setLoopMode(LoopMode.all);
    await _musicPlayer!.play();
  }

  Future<void> stopMusic() async {
    await _musicPlayer?.stop();
  }

  Future<void> playCorrectAnswerSound() async {
    if (!_isSoundEnabled) return;
    _ensurePlayersInitialized();
    await _soundPlayer!.setAudioSource(
      AudioSource.asset('assets/audio/correct_answer.mp3'),
    );
    await _soundPlayer!.setVolume(_soundVolume);
    await _soundPlayer!.play();
  }

  Future<void> playWrongAnswerSound() async {
    if (!_isSoundEnabled) return;
    _ensurePlayersInitialized();
    await _soundPlayer!.setAudioSource(
      AudioSource.asset('assets/audio/wrong_answer.mp3'),
    );
    await _soundPlayer!.setVolume(_soundVolume);
    await _soundPlayer!.play();
  }

  Future<void> playQuizCompleteSound() async {
    if (!_isSoundEnabled) return;
    _ensurePlayersInitialized();
    print('Playing quiz complete sound...');
    await _quizCompletePlayer!.setAudioSource(
      AudioSource.asset('assets/audio/quiz_complete.mp3'),
    );
    await _quizCompletePlayer!.setVolume(_soundVolume);
    await _quizCompletePlayer!.play();
    print('Quiz complete sound started: ${_quizCompletePlayer!.playing}');
  }

  void dispose() {
    _musicPlayer?.dispose();
    _soundPlayer?.dispose();
    _quizCompletePlayer?.dispose();
    _musicPlayer = null;
    _soundPlayer = null;
    _quizCompletePlayer = null;
  }
}
