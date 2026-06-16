import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/profile.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl {
  final SupabaseClient _client;

  ProfileRepositoryImpl(this._client);

  Future<Profile?> getProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    final email = _client.auth.currentUser?.email;
    return ProfileModel.fromJson({...data, 'email': email ?? ''});
  }

  Future<Profile> updateProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    final data = await _client
        .from('profiles')
        .update(updates)
        .eq('id', userId)
        .select()
        .single();
    final email = _client.auth.currentUser?.email;
    return ProfileModel.fromJson({...data, 'email': email ?? ''});
  }

  Future<String?> uploadAvatar(String userId, Uint8List bytes, String ext) async {
    final path = '$userId/avatar.$ext';
    await _client.storage.from('avatars').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
    return _client.storage.from('avatars').getPublicUrl(path);
  }

  Future<String?> uploadCoverPhoto(String userId, Uint8List bytes, String ext) async {
    final path = '$userId/cover.$ext';
    await _client.storage.from('covers').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
    return _client.storage.from('covers').getPublicUrl(path);
  }
}
