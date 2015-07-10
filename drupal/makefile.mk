mica_current_tag = 1.0.3-dev
mica_branch_version=1.0.x
drupal_version = 7.34
mica_version=$(drupal_version)-$(mica_current_tag)
drupal_org_mica=git.drupal.org:project/obiba_mica.git
obiba-progressbar-version=1.0.0

#
# Mysql db access
#
db_name = drupal
db_user = root
db_pass = 1234

drupal-help:
	@echo
	@echo "Mica Drupal 7 Client"
	@echo
	@echo "Available make targets:"
	@echo "  all          : Clean & setup Drupal with a symlink to Mica modules in target directory and import drupal.sql"
	@echo "  setup-drupal : Setup Drupal with Mica modules in target directory"
	@echo

drupal: clean setup-drupal www import-sql settings bootstrap enable-mica angular-app enable-obiba-agate devel enable-mica-data-access less-css jquery_update datatables obiba-progressbar cc

drupal-clean:
	rm -rf target/drupal

setup-drupal:
	drush make --prepare-install drupal/drupal-basic.make target/drupal && \
	chmod -R a+w target/drupal && \
	ln -s $(CURDIR)/../mica-drupal7 $(CURDIR)/target/drupal/sites/all/modules/obiba_mica && \
	ln -s $(CURDIR)/../bootstrap-drupal7 $(CURDIR)/target/drupal/sites/all/themes/obiba_bootstrap && \
	ln -s $(CURDIR)/../agate-drupal7 $(CURDIR)/target/drupal/sites/all/modules/obiba_agate && \
	ln -s $(CURDIR)/../protobuf-drupal7  $(CURDIR)/target/drupal/sites/all/modules/obiba_protobuf

www:
	sudo rm -f /var/www/html/drupal && \
	sudo ln -s $(CURDIR)/target/drupal /var/www/html/drupal && \
	sudo chown -R www-data:www-data /var/www/html/drupal

dump-sql:
	mysqldump -u $(db_user) --password=$(db_pass) --hex-blob $(db_name) --result-file="drupal/drupal-$(drupal_version).sql"

create-sql:
	mysql -u $(db_user) --password=$(db_pass) -e "drop database if exists $(db_name); create database $(db_name);"

import-sql: create-sql
	mysql -u $(db_user) --password=$(db_pass) $(db_name) < "drupal/drupal-$(drupal_version).sql"

settings:
	sed  's/@db_name@/$(db_name)/g' drupal/settings.php | sed  's/@db_user@/$(db_user)/g' | sed  's/@db_pass@/$(db_pass)/g'  > target/drupal/sites/default/settings.php
	cp drupal/.htaccess target/drupal

enable-mica:
	cd target/drupal && \
	drush en -y obiba_mica

enable-mica-data-access:
	cd target/drupal && \
	drush en -y obiba_mica_data_access_request

enable-obiba-agate:
	cd target/drupal && \
	drush en -y obiba_agate

cptp:
	cd target/drupal && \
	rm -rf sites/all/modules/cptp/ && \
	cp -r ~/Dropbox/P3G-OBiBa-Share/mlstr-seed/drupal/cptp sites/all/modules && \
	drush en -y cptp

bootstrap:
	cd target/drupal && \
	drush dl -y bootstrap && \
	drush en -y bootstrap && \
	drush en -y obiba_bootstrap && \
	drush vset -y theme_default obiba_bootstrap && \
	drush vset -y admin_theme seven

less-css:
	lessc $(CURDIR)/../bootstrap-drupal7/less/style.less $(CURDIR)/../bootstrap-drupal7/css/style.css
	lessc $(CURDIR)/../bootstrap-drupal7/less/obiba.less $(CURDIR)/../bootstrap-drupal7/css/obiba.css

jquery_update:
	cd target/drupal && \
	drush dl -y jquery_update && \
	drush en -y jquery_update && \
	drush vset -y jquery_update_jquery_version 1.8 && \
	drush vset -y jquery_update_jquery_admin_version 1.8

devel:
	cd target/drupal && \
	drush dl -y devel && \
	drush en -y devel

chart-enable:
	cd target/drupal && \
	drush highcharts-download && \
	drush en -y charts_highcharts

datatables: datatables-download datatables-plugins-download

datatables-download:
	cd target/drupal && \
	drush datatables-download


datatables-plugins-download:
	cd target/drupal && \
	drush datatables-plugins-download

obiba-progressbar:
	cd target/drupal && \
	drush vset -y obiba-progressbar-lib obiba-progressbar-$(obiba-progressbar-version) && \
	drush vset -y obiba-progressbar-file "dist/obiba-progressbar" && \
	drush obiba-progressbar-download $(obiba-progressbar-version)

angular-app:
	cd target/drupal && \
	drush en -y obiba_main_app_angular && \
	rm -rf sites/all/libraries/angular-app  && \
	drush angular-app

cc:
	cd target/drupal && drush cc all
