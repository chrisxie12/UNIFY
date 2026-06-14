import { Alert, Pressable, ScrollView, Switch, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import * as Haptics from 'expo-haptics';
import { useState } from 'react';
import { useAppStore } from '../store/useAppStore';
import { supabase } from '../lib/supabase';

function SettingsRow({
  label, sub, onPress, danger = false, showArrow = true,
}: {
  label: string; sub?: string; onPress?: () => void; danger?: boolean; showArrow?: boolean;
}) {
  return (
    <Pressable
      onPress={onPress}
      disabled={!onPress}
      className="flex-row items-center justify-between px-5 py-4 active:bg-surface"
    >
      <View className="flex-1">
        <Text className={`font-body-semi text-sm ${danger ? 'text-red' : 'text-primary'}`}>
          {label}
        </Text>
        {sub ? <Text className="font-body text-xs text-tertxt mt-0.5">{sub}</Text> : null}
      </View>
      {showArrow && <Text className="text-tertxt text-base ml-3">›</Text>}
    </Pressable>
  );
}

function ToggleRow({ label, sub, value, onChange }: {
  label: string; sub?: string; value: boolean; onChange: (v: boolean) => void;
}) {
  return (
    <View className="flex-row items-center justify-between px-5 py-4">
      <View className="flex-1 pr-4">
        <Text className="font-body-semi text-sm text-primary">{label}</Text>
        {sub ? <Text className="font-body text-xs text-tertxt mt-0.5">{sub}</Text> : null}
      </View>
      <Switch
        value={value}
        onValueChange={(v) => { Haptics.selectionAsync(); onChange(v); }}
        trackColor={{ true: '#0066FF', false: '#E5E7EB' }}
        thumbColor="#FFFFFF"
      />
    </View>
  );
}

function SectionDivider({ title }: { title: string }) {
  return (
    <View className="px-5 pt-6 pb-2">
      <Text className="font-body-semi text-xs text-tertxt uppercase tracking-wide">{title}</Text>
    </View>
  );
}

function Separator() {
  return <View className="mx-5 h-px bg-border" />;
}

export default function SettingsScreen() {
  const router      = useRouter();
  const setOnboarded = useAppStore((s) => s.setOnboarded);
  const profile      = useAppStore((s) => s.profile);

  const [notifs,   setNotifs]   = useState(true);
  const [darkMode, setDarkMode] = useState(false);
  const [online,   setOnline]   = useState(true);
  const [visible,  setVisible]  = useState(true);

  function handleSignOut() {
    Alert.alert('Log out', 'Are you sure you want to log out?', [
      { text: 'Cancel', style: 'cancel' },
      {
        text: 'Log out',
        style: 'destructive',
        onPress: async () => {
          setOnboarded(false);
          await supabase.auth.signOut();
          router.replace('/get-started');
        },
      },
    ]);
  }

  function handleDeleteAccount() {
    Alert.alert(
      'Delete Account',
      'This will permanently delete your UNIFY account and all your data. This action cannot be undone.',
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Delete', style: 'destructive', onPress: () => {} },
      ],
    );
  }

  return (
    <SafeAreaView className="flex-1 bg-white" edges={['top']}>
      {/* Header */}
      <View className="flex-row items-center px-5 pt-4 pb-3 border-b border-border">
        <Pressable
          onPress={() => router.back()}
          hitSlop={12}
          className="w-10 h-10 rounded-full bg-surface items-center justify-center active:opacity-70"
        >
          <Text className="font-heading text-base text-primary">←</Text>
        </Pressable>
        <Text className="font-heading text-xl text-primary ml-3">Settings</Text>
      </View>

      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{ paddingBottom: 48 }}
      >
        {/* Account */}
        <SectionDivider title="Account" />
        <View className="bg-white rounded-2xl mx-4 border border-border overflow-hidden">
          <SettingsRow
            label="Edit Profile"
            sub={profile.fullName || 'Set up your profile'}
            onPress={() => router.push('/onboarding')}
          />
          <Separator />
          <SettingsRow
            label="Change Phone Number"
            onPress={() => {}}
          />
          <Separator />
          <SettingsRow
            label="Verify Student ID"
            sub={profile.fullName ? 'Increases match trust' : undefined}
            onPress={() => {}}
          />
          <Separator />
          <SettingsRow
            label="Delete Account"
            danger
            onPress={handleDeleteAccount}
          />
        </View>

        {/* Preferences */}
        <SectionDivider title="Preferences" />
        <View className="bg-white rounded-2xl mx-4 border border-border overflow-hidden">
          <ToggleRow
            label="Push Notifications"
            sub="Matches, messages, hub activity"
            value={notifs}
            onChange={setNotifs}
          />
          <Separator />
          <ToggleRow
            label="Dark Mode"
            sub="Coming soon"
            value={darkMode}
            onChange={setDarkMode}
          />
          <Separator />
          <SettingsRow
            label="Language"
            sub="English"
            onPress={() => {}}
          />
        </View>

        {/* Privacy */}
        <SectionDivider title="Privacy" />
        <View className="bg-white rounded-2xl mx-4 border border-border overflow-hidden">
          <ToggleRow
            label="Show Online Status"
            value={online}
            onChange={setOnline}
          />
          <Separator />
          <ToggleRow
            label="Public Profile"
            sub="Visible to students in your school"
            value={visible}
            onChange={setVisible}
          />
          <Separator />
          <SettingsRow
            label="Blocked Users"
            onPress={() => {}}
          />
        </View>

        {/* Support */}
        <SectionDivider title="Support" />
        <View className="bg-white rounded-2xl mx-4 border border-border overflow-hidden">
          <SettingsRow label="Help Center" onPress={() => {}} />
          <Separator />
          <SettingsRow label="Report a Bug" onPress={() => {}} />
          <Separator />
          <SettingsRow label="Contact Us" onPress={() => {}} />
        </View>

        {/* About */}
        <SectionDivider title="About" />
        <View className="bg-white rounded-2xl mx-4 border border-border overflow-hidden">
          <SettingsRow label="Terms of Use" onPress={() => {}} />
          <Separator />
          <SettingsRow label="Privacy Policy" onPress={() => {}} />
          <Separator />
          <SettingsRow
            label="App Version"
            sub="1.0.0 (Build 1)"
            showArrow={false}
          />
        </View>

        {/* Log Out */}
        <View className="mx-4 mt-6">
          <Pressable
            onPress={handleSignOut}
            className="rounded-full py-4 items-center border border-red active:opacity-70"
          >
            <Text className="font-body-semi text-sm text-red">Log Out</Text>
          </Pressable>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}
