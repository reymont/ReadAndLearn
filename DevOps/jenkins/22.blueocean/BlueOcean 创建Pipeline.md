BlueOcean 创建Pipeline_w3cschool https://www.w3cschool.cn/jenkins/jenkins-nqkh28q1.html

BlueOcean可以轻松地在Jenkins创建Pipeline。Pipeline可以从现有的“Jenkinsfile”或由Blue Ocean Pipeline Editor创建的新Jenkinsfile文件创建 。Pipeline创建工作流程通过清晰，易于理解的步骤指导用户完成此过程。
启动Pipeline创建

在BlueOcean界面的顶部，是一个“ New Pipeline ”按钮，启动Pipeline创建工作流程。
BlueOcean 创建Pipeline
在新的Jenkins实例中，没有作业或Pipeline，仪表板为空，Blue Ocean还将显示“Creat a new Pipeline”的消息框。
BlueOcean 创建Pipeline
为Git存储库创建Pipeline

要从Git存储库创建Pipeline，首先选择“Git”作为源代码控制系统。
BlueOcean 创建Pipeline
然后输入Git Repository的URL，并可选择选择要使用的凭据。如果下拉列表中没有显示所需的凭据，则可以使用“添加”按钮添加。
完成后，点击“创建Pipeline”。BlueOcean将查看所选存储库的所有分支，并将为包含a的每个分支启动Pipeline运行Jenkinsfile。
BlueOcean 创建Pipeline
为GitHub存储库创建Pipeline

要从GitHub创建Pipeline，首先选择“GitHub”作为源代码控制系统。
BlueOcean 创建Pipeline
提供一个GitHub访问令牌

如果这是当前登录用户首次运行Pipeline创建，Blue Ocean将要求 GitHub访问令牌 允许Blue Ocean访问您的组织和存储库。
BlueOcean 创建Pipeline
如果您尚未创建访问令牌，请单击提供的链接，Blue Ocean将导航到 GitHub上的右侧页面，自动选择所需的相应权限。
BlueOcean 创建Pipeline
选择一个GitHub帐户或组织

Github上的所有存储库都由所有者，帐户或组织分组。创建Pipeline时，Blue Ocean会反映该结构，要求用户选择拥有存储库的帐户或组织，从中添加Pipeline。
BlueOcean 创建Pipeline

从这里，BlueOcean 提供两种风格的Pipeline创作，即 "single Pipeline" or "discover all Pipelines”。
来自单个存储库的新Pipeline 


选择“新Pipeline ”允许用户为单个存储库选择并创建Pipeline 。
BlueOcean 创建Pipeline
选择存储库后，Blue Ocean将扫描该存储库中的所有分支，并为根文件夹中包含“Jenkinsfile”的每个分支创建一个Pipeline。然后BlueOcean将在此过程中运行为每个分支创建的Pipeline。
如果所选存储库中没有分支机构有“Jenkins文件”，Blue Ocean将提供该存储库的“创建新Pipeline”，使用户到 BlueOcean Pipeline编辑器创建Jenkinsfile一个新的Pipeline并添加新的Pipeline。
自动发现Pipeline


选择“自动发现Pipeline”扫描属于所选所有者的所有存储库，并将为根文件夹中包含“Jenkinsfile”的每个分支创建一个Pipeline。
BlueOcean 创建Pipeline

当这些存储库中已有Jenkinsfile条目时，此选项对于在组织中的所有存储库添加Pipeline是有用的。不包含Jenkinsfile条目的存储库将被忽略。要Jenkinsfile在没有单个存储库中创建新的存储库，请改用“ "New Pipeline”选项。