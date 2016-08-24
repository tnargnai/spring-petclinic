This project is packaged by Habitat with the plan.sh, config, and hooks in this directory. This is provided for example purposes for others to draw from to build their own Java web applications that run under Tomcat.

By default, `spring-petclinic` will use its HSQL in-memory database, which requires no additional configuration. However, the application supports connecting to a MySQL database. To provide this as an example setup, we run `core/mysql` on a separate system with Habitat. The `app_username` and `app_password` configuration needs to be set for MySQL. For example, this `mysql-petclinic.toml`:

```
root_password = "zanzibar"
app_username  = "pc"
app_password  = "pc"
bind          = "0.0.0.0"
```

Then start MySQL, for example, with Docker:

```
docker run -it -p 3306:3306 -e HAB_MYSQL="$(cat mysql-petclinic.toml)" core/mysql --bind database:mysql.default
```

This package configures the application at run time with `-D` command-line options for `catalina.sh`. These are set with `server.catalina-opts`. The settings `database.username`, `database.password`, and `database.use-hsqldb` are required. For example, this `spring-petclinic.toml`:

```
[server]
catalina-opts = "-Djava.security.egd=file:/dev/./urandom -Djdbc.driverClassName=com.mysql.jdbc.Driver -Djdbc.initLocation=classpath:db/mysql/initDB.sql -Djdbc.dataLocation=classpath:db/mysql/populateDB.sql -Djdbc.username=pc -Djdbc.password=pc -Djpa.database=MYSQL -Djdbc.url=jdbc:mysql://172.17.0.3:3306/petclinic"

[database]
username = "pc"
password = "pc"
use-hsqldb = false
```

We have to use the `-D` "jdbc" options here because the `data-access.properties` file is hardcoded in the application to come from the class path, and we don't have a way to override that with another properties file. When packaging your own Java application with Habitat, we strongly recommend writing it so that any configuration properties can be managed with Habitat as `config` [files](https://www.habitat.sh/docs/create-packages-configure/).

Once the `toml` file above is created, the spring-petclinic application can be run, for example, in Docker:

```
docker run -it -p 8080:8080 -e HAB_SPRING_PETCLINIC="$(cat spring-petclinic.toml)" -it core/spring-petclinic --peer 172.17.0.3 --bind database:mysql.default
```

Replace `172.17.0.3` with the IP address of the MySQL container started earlier.
