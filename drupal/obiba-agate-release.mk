agate_mica_branch_version=1.x
agate_drupal_branch_version=7.x
agate_tag_agate_version=1.4
agate_branch=$(agate_drupal_branch_version)-$(agate_mica_agate_branch_version)
agate_version_agate=$(agate_drupal_branch_version)-$(agate_tag_agate_version)

#drupal.org repositories :
drupal_org_agate-drupal7=git.drupal.org:project/obiba_agate.git

#GitHub repositories :
gitHub_mica_agate-drupal7=https://github.com/obiba/agate-drupal7.git

#Repositories folders
agate_git_hub=target/github_repo
agate_git_drupal=target/git_drupal_repo

#
# Release Drupal.org
#

release-agate:
	$(call release-drupal-module,$(agate_branch),$(agate_drupal_org_agate-drupal7),$(agate_version_agate),$(agate_gitHub_mica_agate-drupal7),agate_agate-drupal7,agate_obiba_agate)
