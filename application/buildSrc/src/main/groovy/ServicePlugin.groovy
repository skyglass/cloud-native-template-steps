import org.gradle.api.Plugin
import org.gradle.api.Project

class ServicePlugin implements Plugin<Project> {

    @Override
    void apply(Project project) {

        project.apply(plugin: 'org.springframework.boot')
        project.apply(plugin: DockerBuildLocallyPlugin)
        project.apply(plugin: DockerBuildRemotePlugin)

        project.dependencies {

            if (!project.ext.springBootVersion.startsWith("3")) {
                implementation "org.springframework.cloud:spring-cloud-starter-sleuth"
                implementation "org.springframework.cloud:spring-cloud-sleuth-zipkin"
                implementation "io.eventuate.tram.springcloudsleuth:eventuate-tram-spring-cloud-sleuth-tram-starter"
            }

            implementation 'org.springdoc:springdoc-openapi-starter-webmvc-ui'

        }

    }
}
