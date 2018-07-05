FROM jenkins/jenkins:lts

# Install Jenkins plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

ENV DEBIAN_FRONTEND noninteractive

USER root

# Install PHP 7.1
RUN apt-get update -y && apt-get install -y \
    apt-transport-https lsb-release ca-certificates && \
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list

RUN apt-get update -y && apt-get install -y \
    php7.1 \
    php7.1-cli \
    php7.1-common \
    php7.1-dev \
    php7.1-xml

# Install PHP QA tools
RUN wget -O phpunit https://phar.phpunit.de/phpunit-7.phar                 && mv phpunit /bin/ && chmod +x /bin/phpunit
RUN wget -O phpcs   https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar && mv phpcs   /bin/ && chmod +x /bin/phpcs
RUN wget -O phploc  https://phar.phpunit.de/phploc.phar                    && mv phploc  /bin/ && chmod +x /bin/phploc
RUN wget -O pdepend http://static.pdepend.org/php/latest/pdepend.phar      && mv pdepend /bin/ && chmod +x /bin/pdepend
RUN wget -O phpmd   http://static.phpmd.org/php/latest/phpmd.phar          && mv phpmd   /bin/ && chmod +x /bin/phpmd
RUN wget -O phpcpd  https://phar.phpunit.de/phpcpd.phar                    && mv phpcpd  /bin/ && chmod +x /bin/phpcpd
RUN wget -O phpdox  http://phpdox.de/releases/phpdox.phar                  && mv phpdox  /bin/ && chmod +x /bin/phpdox

# Create PHP template <- this gets removed when the volume is mounted I think
RUN mkdir -p $JENKINS_HOME/jobs/php-template  && \
    wget https://raw.github.com/sebastianbergmann/php-jenkins-template/master/config.xml && \
    mv config.xml $JENKINS_HOME/jobs/php-template/ && \
    chown -R jenkins:jenkins $JENKINS_HOME/jobs/php-template

USER jenkins
