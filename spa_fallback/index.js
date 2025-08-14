'use strict';
exports.handler = async (event) => {
    const request = event.Records[0].cf.request;
    const uri = request.uri;

    if (!uri.startsWith('/api/') && !uri.startsWith('/auth/') && !uri.includes('.')) {
        request.uri = '/index.html';
    }
    return request;
};