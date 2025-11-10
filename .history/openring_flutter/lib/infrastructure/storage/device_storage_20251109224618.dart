import 'package:shared_preferences/shared_preferences.dart';

/// 管理设备记忆的存储服务
class DeviceStorage {
  static const String _keyLastDevice = 'last_device';
  static const String _keyRememberDevice = 'remember_device';
  
  /// 保存上次连接的设备
  static Future<void> saveLastDevice({
    required String name,
    required String address,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastDevice, '$name|$address');
  }
  
  /// 获取上次连接的设备
  static Future<StoredDeviceInfo?> getLastDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyLastDevice);
    if (data == null) return null;
    
    final parts = data.split('|');
    if (parts.length != 2) return null;
    
    return StoredDeviceInfo(name: parts[0], address: parts[1]);
  }
  
  /// 清除设备记忆
  static Future<void> clearLastDevice() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLastDevice);
  }
  
  /// 设置是否记住设备
  static Future<void> setRememberDevice(bool remember) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRememberDevice, remember);
  }
  
  /// 获取是否记住设备的设置
  static Future<bool> getRememberDevice() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRememberDevice) ?? true; // 默认记住
  }
}

class StoredDeviceInfo {
  final String name;
  final String address;
  
  StoredDeviceInfo({required this.name, required this.address});
}
