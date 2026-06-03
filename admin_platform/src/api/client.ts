import axios from 'axios';
import { useAdminAuth } from '@/store/auth';

const BASE = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost';

export const api = axios.create({ baseURL: BASE });

api.interceptors.request.use((config) => {
  const token = useAdminAuth.getState().accessToken;
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

api.interceptors.response.use(
  (r) => r,
  async (err) => {
    if (err.response?.status === 401 && !err.config._retried) {
      err.config._retried = true;
      try {
        await useAdminAuth.getState().refresh();
        const token = useAdminAuth.getState().accessToken;
        if (token) err.config.headers.Authorization = `Bearer ${token}`;
        return api.request(err.config);
      } catch {
        useAdminAuth.getState().logout();
      }
    }
    return Promise.reject(err);
  },
);
