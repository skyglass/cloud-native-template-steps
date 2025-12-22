import org.gradle.api.Plugin;
import org.gradle.api.Project;
import org.eclipse.jgit.api.Git;

import java.io.File;
import java.io.IOException;

public class GitRepositoryUrlPlugin implements Plugin<Project> {
    @Override
    public void apply(Project project) {
        Git git;
        try {
            git = Git.open(findGitDir(project));
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        String originUrl = git.getRepository().getConfig().getString("remote", "origin", "url");
        System.out.println("Origin URL: " + originUrl);
        String url = originUrl
                        .replace(".git", "")
                        .replace("https://github.com/", "")
                        .replace("git@github.com:", "");
        System.out.println("repository: " + url);
        project.getExtensions().getExtraProperties().set("gitRepository", url);
        git.close();
    }

    private static File findGitDir(Project project) {
        File dir = project.getRootDir();
        while (dir != null) {
            File gitDir = new File(dir, ".git");
            if (gitDir.exists() && gitDir.isDirectory()) {
                return gitDir;
            }
            if (dir.getParentFile() == null) {
                throw new RuntimeException("Cannot find .git directory");
            }
            dir = dir.getParentFile();
        }
        throw new RuntimeException("Cannot find .git directory");
    }
}
