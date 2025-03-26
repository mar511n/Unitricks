// make a http request to the database server
import axios from 'axios';

export function CallBackendFunc(url, uname, passwd, fname, args) {
    const axiosInstance = axios.create({
        baseURL: url,
        method: 'post',
        auth: {
            username: uname,
            password: passwd
        },
        params: {
            fname: fname,
        },
        withCredentials: true
    });
    return axiosInstance.request({data: args});
}
