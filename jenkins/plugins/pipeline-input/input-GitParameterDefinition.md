

https://jenkins.io/doc/pipeline/steps/pipeline-input-step/

$class: GitParameterDefinition

When used, this parameter will present a build-time a choice to select a Git tag (or revision number) which set a parameter for parametrized build.

Be aware that git does not allow us get additional information (like author/commmit date) from a remote URL this plugin will silently clone the project when your workspace is empty. This may take a long time when we have a slow connection and/or the checkout is big.

Often the parameter defined in the "Name" field is used to specify the branch of the git checkout.

name
The name of the parameter.
Type: String

type
    The type of the list of parameters:
    Tag - list of all commit tags in repository - returns Tag Name
    Branch - list of all branch in repository - returns Branch Name
    Revision - list of all revision sha1 in repository followed by its author and date - returns Tag SHA1
    Type: String

defaultValue
    This value is returned when list is empty.
    Type: String

description
    A description that will be shown to the user later.
    Type: String

branch
    Name of branch to look in. Used only if listing revisions.
    Type: String

branchFilter
    Regex used to filter displayed branches. If blank, the filter will default to ".*". 
    Remote branches will be listed with the remote name first. E.g., "origin/master"
    Type: String

tagFilter
    This parameter is used to get tag from git. 
    If is blank, parameter is set to "*". 
    Properly is executed command: git tag -l "*" or git tag -l "$tagFilter".
    Type: String

sortMode
    Select how to sort the downloaded parameters. Only applies to a branch or a tag.
    none
    ascending smart
    descending smart
    ascending
    descending
    When smart sorting is chosen, the compare treats a sequence of digits as a single character.
    Values:

NONE
ASCENDING_SMART
DESCENDING_SMART
ASCENDING
DESCENDING
selectedValue
Which value is selected, after loaded parameters. 
If you choose 'default', but default value is not present on the list, nothing is selected.
Values:

NONE
TOP
DEFAULT
useRepository
If in the task is defined multiple repositories parameter specifies which the repository is taken into account. 
If the parameter is not defined, is taken first defined repository. 
The parameter is a regular expression which is compared with a URL repository.
Type: String

quickFilterEnabled
When this option is enabled will show a text field. 
Parameter is filtered on the fly.
Type: boolean