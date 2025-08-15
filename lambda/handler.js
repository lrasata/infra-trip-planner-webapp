const corsHeaders = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
    "Access-Control-Allow-Methods": "GET,OPTIONS",
};

exports.handler = async (event) => {
    const { dataType, namePrefix, countryCode } = event.queryStringParameters || {};
    const customAuth = event.headers?.['X-Custom-Auth'] || event.headers?.['x-custom-auth'];

    if (customAuth !== process.env.CUSTOM_AUTH_SECRET) {
        return {
            statusCode: 403,
            headers: corsHeaders,
            body: JSON.stringify({ error: "Forbidden: Invalid custom auth header" })
        };
    }

    if (!dataType || !namePrefix) {
        return {
            statusCode: 400,
            headers: corsHeaders,
            body: JSON.stringify({ error: "Missing query parameter" }),
        };
    }

    const API_COUNTRIES_GEO_DB_URL = process.env.API_COUNTRIES_GEO_DB_URL;
    const API_CITIES_GEO_DB_URL = process.env.API_CITIES_GEO_DB_URL;
    const urlQuery = `namePrefix=${encodeURIComponent(namePrefix)}&limit=10`;

    let url;
    if (dataType === "country") {
        url = `${API_COUNTRIES_GEO_DB_URL}?${urlQuery}`;
    } else if (dataType === "city") {
        if (!countryCode) {
            return {
                statusCode: 400,
                headers: corsHeaders,
                body: JSON.stringify({ error: "Missing query parameter for City" }),
            };
        }
        url = `${API_CITIES_GEO_DB_URL}?countryIds=${countryCode}&${urlQuery}`;
    } else {
        return {
            statusCode: 400,
            headers: corsHeaders,
            body: JSON.stringify({ error: "Invalid dataType" }),
        };
    }

    try {
        const response = await fetch(url, {
            headers: {
                "X-RapidAPI-Host": process.env.GEO_DB_RAPID_API_HOST,
                "X-RapidAPI-Key": process.env.GEO_DB_RAPID_API_KEY,
            },
        });

        if (!response.ok) throw new Error("Error fetching location data");

        const data = await response.json();

        return {
            statusCode: 200,
            headers: corsHeaders,
            body: JSON.stringify(data),
        };
    } catch (error) {
        return {
            statusCode: 500,
            headers: corsHeaders,
            body: JSON.stringify({ error: error.message }),
        };
    }
};
