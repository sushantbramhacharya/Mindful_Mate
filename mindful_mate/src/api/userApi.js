import { BASE_URL } from "../constants";
import { api } from "./api";

export const userApi=api.injectEndpoints({
    endpoints:(builder)=>({
        login:builder.mutation({
            query:(data)=>({
                url:BASE_URL+'/login',
                method:'POST',
                body:data
            })
        }),
        register:builder.mutation({
            query:(data)=>({
                url:BASE_URL+'/user/register',
                method:'POST',
                body:data
            })
        }),
    })
})

export const {useLoginMutation,useRegisterMutation}=userApi