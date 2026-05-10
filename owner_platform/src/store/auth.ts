import axios from 'axios';
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

const BASE = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost';

export type OwnerProfile = {
  id: string;
  username: string;
  fullName: string;
  email: string;
  avatarUrl: string | null;
};

type AuthState = {
  isAuthenticated: boolean;
  user: OwnerProfile | null;
  accessToken: string | null;
  refreshToken: string | null;
  login: (credentials: { username: string; password: string }) => Promise<void>;
  logout: () => void;
  refresh: () => Promise<void>;
};

export const useAuth = create<AuthState>()(
  persist(
    (set, get) => ({
      isAuthenticated: false,
      user: null,
      accessToken: null,
      refreshToken: null,

      login: async ({ username, password }) => {
        const resp = await axios.post(`${BASE}/account/v1/login`, { username, password });
        const { access_token, refresh_token } = resp.data;

        const profileResp = await axios.get(`${BASE}/account/v1/profile`, {
          headers: { Authorization: `Bearer ${access_token}` },
        });
        const p = profileResp.data;

        set({
          isAuthenticated: true,
          accessToken: access_token,
          refreshToken: refresh_token,
          user: {
            id: p.id,
            username: p.username,
            fullName: `${p.first_name} ${p.last_name}`.trim() || p.username,
            email: p.email,
            avatarUrl: null,
          },
        });
      },

      logout: () =>
        set({ isAuthenticated: false, user: null, accessToken: null, refreshToken: null }),

      refresh: async () => {
        const { refreshToken } = get();
        if (!refreshToken) throw new Error('no refresh token');
        const resp = await axios.post(`${BASE}/account/v1/refresh`, {
          refresh_token: refreshToken,
        });
        set({
          accessToken: resp.data.access_token,
          refreshToken: resp.data.refresh_token,
        });
      },
    }),
    {
      name: 'zs.owner.auth',
      version: 2,
    },
  ),
);
