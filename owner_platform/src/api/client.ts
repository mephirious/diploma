import axios from 'axios';
import { useAuth } from '@/store/auth';

const BASE = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost';

export const api = axios.create({ baseURL: BASE });

api.interceptors.request.use((config) => {
  const token = useAuth.getState().accessToken;
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

api.interceptors.response.use(
  (r) => r,
  async (err) => {
    if (err.response?.status === 401 && !err.config._retried) {
      err.config._retried = true;
      try {
        await useAuth.getState().refresh();
        const token = useAuth.getState().accessToken;
        if (token) err.config.headers.Authorization = `Bearer ${token}`;
        return api.request(err.config);
      } catch {
        useAuth.getState().logout();
      }
    }
    return Promise.reject(err);
  },
);
