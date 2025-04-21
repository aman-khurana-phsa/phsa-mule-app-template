# APP Name

<<Description of the responsibilities of the app>>

For more details please visit the following confluence link: << add the link here >>


### Local Setup
To run this application on anypoint studio, follow the below steps

```
1. Preferences -> Anypoint Studio -> Maven
   Base command line for builds = mvn clean package -nsu -DskipMunitTests
2. Preferences -> Anypoint Studio -> MUnit
   Build parameters for tests execution = -DskipAST -P activate-mule-rtf
3. Run Configuration -> Arguments -> VM arguments
   -Dmule.env=dev
   -Daws.region=ca-central-1
   -Dlog.group.name=
   -Daws.accessKeyId=
   -Daws.secretKey=
```

# Development and Branching Guidelines

### **Branches**
The `main` branch has the latest code, which is:

- finalized & ready to be QA tested code
- this is a protected branch and requires PR
- do not merge incomplete work into this branch as other developers use this branch as their base.

The `release` branch has the latest production code

- production ready code (already tested by QA and planned, approved for released)
- only main or hot-fix branches should PR into this branch
- each PR creates a new version/tag
  - to manually overwrite the version see [gitversion docs](https://gitversion.net/docs/reference/version-increments#manually-incrementing-the-version)


All other branches fall under <storyId>/<feature/bug-title> which indicate work in development (i.e. wip to be later merged to main via PR).

### **Development (WiP)**
To start a work for a new feature, bug, story create a branch derived from the latest `main` branch

```git checkout -b DHT-111/new-feature-title```

Once feature is ready (development is finalized) you can start the PR to main branch.
### **Pull Request (PR)**
Before your changes can be merged into the main or release branch, code review and quality checks have to be completed. Make sure:

- PR is linked to a story/bug (include jira id in the Title)
- Code is complete and finalized (only finalized and QA ready features should be merged!)
- Keep PRs small, introduce only a single feature, fix per PR!
- Title PR/merge {Jira-No}:{Feature Title}
  
### **PROD Release**
When all features for next release are ready in main branch, a PR from the main branch to the release branch will create a new release/version

- only builds from this branch will be used in production
- after production release was deployed, only hot fixes will be applied to this branch (and then merged back to main)
  
## **Additional Resources**
- [GitHub Branching Documentation](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/about-branches)
- [Understanding the GitHub Flow](https://guides.github.com/introduction/flow/)
