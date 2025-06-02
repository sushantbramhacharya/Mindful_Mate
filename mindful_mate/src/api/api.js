
import {createApi, fetchBaseQuery} from '@reduxjs/toolkit/query/react';
import { BASE_URL } from '../constants';

export const api=createApi({
    baseQuery:fetchBaseQuery(
        {
            baseUrl:BASE_URL,
            credentials: 'include',
        }
    ),
    reducerPath:"api",
    tagTypes:['user'],
    endpoints:(builder)=>({})
})