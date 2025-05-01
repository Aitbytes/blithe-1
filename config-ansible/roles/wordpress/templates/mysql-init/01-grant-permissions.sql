-- Grant SELECT permissions to WordPress user for Grafana monitoring
GRANT SELECT ON *.* TO '${WORDPRESS_DB_USER}'@'%';
FLUSH PRIVILEGES;

