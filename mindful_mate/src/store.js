import { configureStore } from "@reduxjs/toolkit";
import { api } from "./api/api";
import userSliceReducer from "./Slices/userSlice";


const store=configureStore({
    //path of the reducer
    reducer:{
        [api.reducerPath]: api.reducer,
        userSlice:userSliceReducer
    },
    devTools:true,
    // Adding the api middleware enables caching, invalidation, polling,
    middleware:(getDefaultMiddleware)=>(
        getDefaultMiddleware().concat(api.middleware)
    )
});

export default store;