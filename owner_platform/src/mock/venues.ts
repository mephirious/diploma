import type { Venue } from '@/types/venue';

export const MOCK_VENUES: Venue[] = [
  {
    id: 'v-almaty-arena',
    name: 'Almaty Arena',
    description:
      'A modern multi-sport complex in the heart of Almaty. Professional-grade pitches, indoor courts, and world-class amenities for athletes of all levels.',
    sports: ['football', 'basketball'],
    address_line1: 'Abay Ave 48',
    address_line2: 'Bostandyk District',
    city: 'Almaty',
    country: 'Kazakhstan',
    location: { lat: 43.222, lng: 76.8512 },
    images: [
      'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=1400',
      'https://images.unsplash.com/photo-1529900748604-07564a03e7a6?w=1400',
      'https://images.unsplash.com/photo-1517649763962-0c623066013b?w=1400',
    ],
    contacts: [
      {
        description: 'Reception',
        phone: '+7 727 250 00 10',
        email: null,
        link: null,
      },
      {
        description: 'Bookings',
        phone: null,
        email: 'bookings@almaty-arena.kz',
        link: null,
      },
      {
        description: 'Website',
        phone: null,
        email: null,
        link: 'https://almaty-arena.kz',
      },
    ],
    timezone: 'Asia/Almaty',
    created_at: '2023-11-02T09:00:00Z',
    updated_at: '2026-04-24T10:00:00Z',
    status: 'active',
  },
  {
    id: 'v-skyline-court',
    name: 'Skyline Court Center',
    description:
      'Premium indoor basketball courts with professional flooring, ambient lighting and an observation lounge. Perfect for pickup games and team practices.',
    sports: ['basketball', 'volleyball'],
    address_line1: 'Dostyk Ave 132',
    address_line2: null as unknown as string | undefined,
    city: 'Almaty',
    country: 'Kazakhstan',
    location: { lat: 43.2386, lng: 76.9562 },
    images: [
      'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=1400',
      'https://images.unsplash.com/photo-1559692048-79a3f837883d?w=1400',
    ],
    contacts: [
      {
        description: 'Main line',
        phone: '+7 727 311 22 00',
        email: null,
        link: null,
      },
    ],
    timezone: 'Asia/Almaty',
    created_at: '2024-02-17T08:00:00Z',
    updated_at: '2026-04-26T15:30:00Z',
    status: 'draft',
  },
  {
    id: 'v-aqua-sprint',
    name: 'Aqua Sprint Pool',
    description:
      'Olympic-size swimming pool with 8 lanes, sauna, and a family leisure zone. Heated year-round.',
    sports: ['swimming'],
    address_line1: 'Rozybakiev 247',
    city: 'Almaty',
    country: 'Kazakhstan',
    location: { lat: 43.2001, lng: 76.8946 },
    images: [
      'https://images.unsplash.com/photo-1519315901367-f34ff9154487?w=1400',
      'https://images.unsplash.com/photo-1576013551627-0cc20b96c2a7?w=1400',
    ],
    contacts: [
      {
        description: 'Front desk',
        phone: '+7 727 398 14 14',
        email: null,
        link: null,
      },
      {
        description: 'Email',
        phone: null,
        email: 'hello@aquasprint.kz',
        link: null,
      },
    ],
    timezone: 'Asia/Almaty',
    created_at: '2023-07-14T12:00:00Z',
    updated_at: '2026-04-20T09:00:00Z',
    status: 'suspended',
  },
  {
    id: 'v-tennis-park',
    name: 'Tennis Park Esentai',
    description:
      'Exclusive tennis club with 6 outdoor and 4 indoor courts. Located near Esentai Mall with stunning mountain views.',
    sports: ['tennis'],
    address_line1: 'Al-Farabi Ave 77',
    city: 'Almaty',
    country: 'Kazakhstan',
    location: { lat: 43.2183, lng: 76.9287 },
    images: [
      'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=1400',
      'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?w=1400',
    ],
    contacts: [
      {
        description: 'Club manager',
        phone: '+7 727 277 00 90',
        email: 'club@tennispark.kz',
        link: null,
      },
    ],
    timezone: 'Asia/Almaty',
    created_at: '2024-05-03T09:30:00Z',
    updated_at: '2026-04-27T17:00:00Z',
    status: 'active',
  },
];
