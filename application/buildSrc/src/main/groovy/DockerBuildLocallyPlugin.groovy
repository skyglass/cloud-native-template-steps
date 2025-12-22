import org.gradle.api.Plugin
import org.gradle.api.Project
import org.gradle.api.tasks.Exec

class DockerBuildLocallyPlugin implements Plugin<Project> {

    @Override
    void apply(Project project) {

        project.apply(plugin: EnsureBuilderPlugin)
        project.apply(plugin: StartDockerRegistryPlugin)

        def args = ["docker", "buildx", "build", "--builder", EnsureBuilderPlugin.BUILDER_NAME, "--build-arg", "baseImageVersion=${project.ext.eventuateExamplesBaseImageVersion}",
                "--platform", "linux/amd64,linux/arm64", "-t", "localhost:5002/${project.name.replace"-main", ""}:${project.ext.imageVersion}", "--output=type=image,push=true,registry.insecure=true",
                "."]

        def task = project.task("buildDockerImageLocally", type: Exec) {

            workingDir(project.projectDir)

            commandLine (args)

            dependsOn(":${project.path}:startDockerRegistry", ":${project.path}:assemble", "createBuilder")
        }

    }
}
