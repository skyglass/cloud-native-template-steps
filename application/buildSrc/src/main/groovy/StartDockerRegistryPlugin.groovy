import org.gradle.api.Plugin;
import org.gradle.api.Project;
import org.gradle.api.tasks.Exec;

public class StartDockerRegistryPlugin implements Plugin<Project> {
    @Override
    public void apply(Project project) {
      project.task("startDockerRegistry", type:Exec) {

          commandLine "sh", "-c", """
if [ "\$(docker inspect -f '{{.State.Running}}' registry 2>/dev/null || true)" != 'true' ]; then
  docker run \\
    -d --restart=always -p "127.0.0.1:5002:5000" --network bridge --name registry \\
    registry:2
fi
"""

      }
    }
}
