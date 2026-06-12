import {
  createContext,
  useCallback,
  useContext,
  useMemo,
  useState,
  type ReactNode,
} from 'react';
import type { PopAccent } from '../theme/tokens';

// Global student state: GPA modules, assignment schedule, timetable,
// profile metrics. Lives outside app/ so expo-router never treats it
// as a route.

export type LetterGrade = 'A' | 'B+' | 'B' | 'C+' | 'C' | 'D+' | 'D' | 'F';
export type Weekday = 'Mon' | 'Tue' | 'Wed' | 'Thu' | 'Fri';

export interface GpaModule {
  readonly id: string;
  readonly code?: string;
  readonly title: string;
  readonly credits: number;
  readonly grade: LetterGrade;
}

export interface NewModuleInput {
  readonly title: string;
  readonly credits: number;
  readonly grade: LetterGrade;
}

export interface Assignment {
  readonly id: string;
  readonly course: string;
  readonly title: string;
  readonly due: string;
  readonly completed: boolean;
}

export interface TimetableSlot {
  readonly id: string;
  readonly day: Weekday;
  readonly start: string;
  readonly end: string;
  readonly course: string;
  readonly room: string;
  readonly accent: PopAccent;
}

export interface ProfileMetrics {
  readonly name: string;
  readonly initials: string;
  readonly school: string;
  readonly programme: string;
  readonly level: string;
  readonly verified: boolean;
}

const GRADE_POINTS: Record<LetterGrade, number> = {
  A: 4.0,
  'B+': 3.5,
  B: 3.0,
  'C+': 2.5,
  C: 2.0,
  'D+': 1.5,
  D: 1.0,
  F: 0.0,
};

const MODULES: readonly GpaModule[] = [
  { id: 'mod-1', code: 'COE 152', title: 'Circuit Theory', credits: 3, grade: 'A' },
  { id: 'mod-2', code: 'MATH 158', title: 'Calculus II', credits: 4, grade: 'B+' },
  { id: 'mod-3', code: 'COE 160', title: 'Intro to Programming', credits: 3, grade: 'A' },
  { id: 'mod-4', code: 'PHY 154', title: 'Applied Electricity', credits: 3, grade: 'B' },
  { id: 'mod-5', code: 'ENGL 158', title: 'Communication Skills', credits: 2, grade: 'C+' },
];

const INITIAL_ASSIGNMENTS: readonly Assignment[] = [
  {
    id: 'asg-1',
    course: 'COE 152',
    title: 'Lab report: RC transient response',
    due: 'Fri · 17:00',
    completed: false,
  },
  {
    id: 'asg-2',
    course: 'MATH 158',
    title: 'Problem set 6 — integration by parts',
    due: 'Mon · 09:00',
    completed: false,
  },
  {
    id: 'asg-3',
    course: 'COE 160',
    title: 'Build a CLI grade calculator',
    due: 'Wed · 23:59',
    completed: true,
  },
  {
    id: 'asg-4',
    course: 'ENGL 158',
    title: 'Group presentation outline',
    due: 'Thu · 12:00',
    completed: false,
  },
];

const TIMETABLE: readonly TimetableSlot[] = [
  { id: 'tt-1', day: 'Mon', start: '08:00', end: '10:00', course: 'COE 152 · Circuit Theory', room: 'PB 207', accent: 'blue' },
  { id: 'tt-2', day: 'Mon', start: '13:00', end: '15:00', course: 'MATH 158 · Calculus II', room: 'CCB 3', accent: 'yellow' },
  { id: 'tt-3', day: 'Tue', start: '10:00', end: '12:00', course: 'COE 160 · Intro to Programming', room: 'Lab C', accent: 'green' },
  { id: 'tt-4', day: 'Wed', start: '08:00', end: '10:00', course: 'PHY 154 · Applied Electricity', room: 'PB 101', accent: 'red' },
  { id: 'tt-5', day: 'Wed', start: '14:00', end: '16:00', course: 'COE 152 · Circuits Lab', room: 'Lab A', accent: 'blue' },
  { id: 'tt-6', day: 'Thu', start: '11:00', end: '13:00', course: 'ENGL 158 · Communication Skills', room: 'GF 12', accent: 'yellow' },
  { id: 'tt-7', day: 'Fri', start: '09:00', end: '11:00', course: 'MATH 158 · Tutorial', room: 'CCB 3', accent: 'green' },
  { id: 'tt-8', day: 'Thu', start: '12:00', end: '14:00', course: 'GES 161 · Study Group', room: 'Lib 2F', accent: 'red' },
];

const PROFILE: ProfileMetrics = {
  name: 'Kwame E.',
  initials: 'KE',
  school: 'KNUST',
  programme: 'BSc Computer Engineering',
  level: 'Level 100',
  verified: true,
};

interface AppState {
  readonly modules: readonly GpaModule[];
  readonly assignments: readonly Assignment[];
  readonly timetable: readonly TimetableSlot[];
  readonly profile: ProfileMetrics;
  readonly gpa: number;
  readonly totalCredits: number;
  readonly pendingAssignments: number;
  readonly toggleAssignment: (id: string) => void;
  readonly addModule: (input: NewModuleInput) => void;
}

const AppContext = createContext<AppState | null>(null);

// getDay(): 0 = Sunday … 6 = Saturday; weekends have no timetable.
const WEEKDAY_BY_GETDAY: readonly (Weekday | null)[] = [
  null,
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  null,
];

export function currentWeekday(): Weekday | null {
  return WEEKDAY_BY_GETDAY[new Date().getDay()] ?? null;
}

export function AppProvider({ children }: { children: ReactNode }) {
  const [modules, setModules] = useState<readonly GpaModule[]>(MODULES);
  const [assignments, setAssignments] =
    useState<readonly Assignment[]>(INITIAL_ASSIGNMENTS);

  const toggleAssignment = useCallback((id: string) => {
    setAssignments((prev) =>
      prev.map((a) => (a.id === id ? { ...a, completed: !a.completed } : a)),
    );
  }, []);

  const addModule = useCallback((input: NewModuleInput) => {
    setModules((prev) => [
      ...prev,
      {
        id: `mod-${Date.now()}-${prev.length}`,
        title: input.title,
        credits: input.credits,
        grade: input.grade,
      },
    ]);
  }, []);

  const value = useMemo<AppState>(() => {
    const totalCredits = modules.reduce((sum, m) => sum + m.credits, 0);
    const gpa =
      totalCredits === 0
        ? 0
        : modules.reduce(
            (sum, m) => sum + GRADE_POINTS[m.grade] * m.credits,
            0,
          ) / totalCredits;
    return {
      modules,
      assignments,
      timetable: TIMETABLE,
      profile: PROFILE,
      gpa,
      totalCredits,
      pendingAssignments: assignments.filter((a) => !a.completed).length,
      toggleAssignment,
      addModule,
    };
  }, [modules, assignments, toggleAssignment, addModule]);

  return <AppContext.Provider value={value}>{children}</AppContext.Provider>;
}

export function useApp(): AppState {
  const ctx = useContext(AppContext);
  if (ctx === null) {
    throw new Error('useApp must be called inside <AppProvider>');
  }
  return ctx;
}
