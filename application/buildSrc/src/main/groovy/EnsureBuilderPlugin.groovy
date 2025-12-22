import org.gradle.api.Plugin
import org.gradle.api.Project
import org.gradle.api.tasks.Exec

class EnsureBuilderPlugin implements Plugin<Project> {

    static final String BUILDER_NAME = "lp-builder"

    @Override
    void apply(Project project) {


        project.task("createBuilder", type: Exec) {

            workingDir(project.projectDir)

            commandLine "bash", "-c", "(docker buildx ls | grep ${BUILDER_NAME}) || docker buildx create --name ${BUILDER_NAME} --driver-opt network=host --use"

        }

    }
}
