import org.gradle.api.Plugin
import org.gradle.api.Project
import org.gradle.api.tasks.Exec

class DockerBuildRemotePlugin implements Plugin<Project> {

    @Override
    void apply(Project project) {

        project.apply(plugin: EnsureBuilderPlugin)

        project.task("buildDockerImageRemote", type: Exec) {

            workingDir(project.projectDir)

            commandLine "docker", "buildx", "build", "--builder", EnsureBuilderPlugin.BUILDER_NAME, "--build-arg", "baseImageVersion=${project.ext.eventuateExamplesBaseImageVersion}",
                        "--platform", "linux/amd64,linux/arm64", "-t", "${project.ext.imageRemoteRegistry}/${project.name.replace"-main", ""}:${project.ext.imageVersion}", "--push",
                    "."

            dependsOn(":${project.path}:assemble", "createBuilder")
        }

    }
}
