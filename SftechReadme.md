# Getting Started

### [点击查看 -> Java版本功能列表](http://confluence.sf-express.com/pages/viewpage.action?pageId=218291856)

### Notice

#### gosuv 说明
* 使用 tools/gosuv/genGosuvConf.sh 生成守护进程【gosuv】所必须的配置文件【config.yml、programs.yml】，脚本中有一些配置项，配置完成后，执行即可
* 1.3.0版本后的run.sh在启动时执行gosuv start-server，停止时执行gosuv shutdown，停止后不再保留gosuv的主进程
* 不使用 gosuv 作为守护进程时，可以选择这个脚本【tools/shell/run.sh】启动/关闭服务
* [gosuv使用说明](http://wiki.sftcwl.com/pages/viewpage.action?pageId=28184779)

#### run.sh 说明
* 必填配置【JAR_PORT】，该变量为java服务的端口，启动时会自动轮询读取该端口暴露的actuator/prometheus（项目需要依赖spring-prometheus 1.3.0版本以上），最长轮询60次，当一次结果出现UP时，认为启动成功
* 可选配置【START_MAX_WAIT、START_SLEEP_SECONDS】，其中START_MAX_WAIT表示启动时的查询次数，默认30次，START_SLEEP_SECONDS表示查询间隔sleep的时间，默认1s
* 可选配置【CHECK_HEALTH_UP】，默认值为0；值为1时表示端口健康检查结果为up后认为启动成功，需要CHECK_URL的uri为actuator/health；值为0时，表示端口执行结果返回不为空则启动成功
* 可选配置【CHECK_URL】，默认为actuator/health，可以修改为actuator/prometheus
* 可选配置【SHOW_CHECK_RESULT】，默认为0，表示执行健康检查时不展示结果；设置为1时，在终端展示健康检查结果

#### 容器化说明
* 参考 [链接](http://confluence.sf-express.com/pages/viewpage.action?pageId=218291693) 进行修改

#### 其他
* 当引用 redis 等包时，需要手动添加配置，配置说明详见：[Java技术栈wiki](http://confluence.sf-express.com/pages/viewpage.action?pageId=218291856)

### Sftech Documentation

* [Java代码开发样板间](https://gitlab.sftcwl.com/java-module/demo)
* [Java技术栈wiki](http://confluence.sf-express.com/pages/viewpage.action?pageId=218291856)
* [Java开发规范](http://confluence.sf-express.com/pages/viewpage.action?pageId=218290481)
* [Java开发入门和使用案例](http://confluence.sf-express.com/pages/viewpage.action?pageId=218291842)

### Reference Documentation

* [Gradle官方文档](https://docs.gradle.org)
* [Spring官方文档](https://docs.spring.io/spring/docs/current/spring-framework-reference/index.html)
* [Spring Web Starter](https://docs.spring.io/spring-boot/docs/{bootVersion}/reference/htmlsingle/#boot-features-developing-web-applications)
* [Spring Boot DevTools](https://docs.spring.io/spring-boot/docs/{bootVersion}/reference/htmlsingle/#using-boot-devtools)
* [Swagger官方文档](https://springdoc.org/)

### Guides

* [Building a RESTful Web Service](https://spring.io/guides/gs/rest-service/)
* [Serving Web Content with Spring MVC](https://spring.io/guides/gs/serving-web-content/)
* [Building REST services with Spring](https://spring.io/guides/tutorials/bookmarks/)

### Additional Links
These additional references should also help you:

* [Gradle Build Scans – insights for your project's build](https://scans.gradle.com#gradle)

