function distance = haversine_distance(lat1, lon1, lat2, lon2)
    % haversineDistance Calculate the great-circle distance between two points
    %   distance = haversineDistance(lat1, lon1, lat2, lon2) calculates the
    %   distance in kilometers between two points on the Earth specified by
    %   latitude and longitude using the Haversine formula. The input
    %   latitudes and longitudes must be in degrees.

    % Earth's radius in kilometers
    R = 6371;

    % Convert degrees to radians
    lat1 = deg2rad(lat1);
    lon1 = deg2rad(lon1);
    lat2 = deg2rad(lat2);
    lon2 = deg2rad(lon2);

    % Difference in coordinates
    dLat = lat2 - lat1;
    dLon = lon2 - lon1;

    % Haversine formula
    a = sin(dLat/2)^2 + cos(lat1) * cos(lat2) * sin(dLon/2)^2;
    c = 2 * atan2(sqrt(a), sqrt(1-a));
    distance = R * c;
end
