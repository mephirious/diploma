import { api } from './client';

export type AccountUser = {
  id: string;
  username?: string;
  first_name?: string;
  last_name?: string;
  email?: string;
  created_at?: string;
};

export const accountApi = {
  getUser: (id: string) =>
    api
      .get<AccountUser>(`/account/v1/users/${encodeURIComponent(id)}`)
      .then((r) => r.data),
};
