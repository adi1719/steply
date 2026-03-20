ZIP:
```
BUILD:
======
mvn clean  install -DskipTests 
or 
mvn -T1C clean package -DskipTests

Java17: (bundled) :
Make sure to run with option "-DskipTests" prior to this line. Otherwise it creates a "steply-dist-test" folder.
./scripts/build-distribution-local-jre.sh /Users/nchandra/.sdkman/candidates/java/17.0.17-tem /tmp/steply-dist
(also creates "steply-0.1.0-SNAPSHOT-local.zip" in /tmp)
(Bundles JRE and creates final zip under /tmp folder)
- Upload it manually with renaming/matching the version in "VERSION.txt" file. 
(or you can update the "VERSION.txt" file before building, then it will be same as the zip name)
- But 1st push a release tag(see below) and let GitHub Bot create a no-jre release, then you update the install.sh to latest version, then upload.

------
Java17: (no-jre)
./scripts/build-distribution-no-jre.sh /tmp/steply-dist
(update the VERSION.txt for a new version. )
(Then after the build done, just update VERSION in "install_no_jre.sh" to point to the new release.)

<<Steps>>
1. Update "VERSION.txt" to "202603DD.nn"
  => Wait for 2min for Action build to complete 
2. [AUTO] Build with no-jre script (AUTO triggered by ci.yml workflow, but you can also run it manually)
3. Create a new tag "202603DD.nn" and push it.
4. Then it triggers the auto-upload release and 
  -> AUTO creates a PR to update "install_no_jre.sh" and "install.sh" file with the new tag.
5. Then you can merge the PR : Handles and points to latest release in "install_no_jre.sh" a
  -> Then run the Integration test job manually now to check the latest version is ok.
6. For "install.sh" file. : Locally build and then upload the zip file to the release(edit and drop the file).

For Automatic Release to "Releases" in GitHub:
---------
git tag 20260314.01
git push origin 20260314.01

------
Java8: (bundled)
(pom has changed to support java17+, so check the earlier POM to get a correct java8 bundled build)
./scripts/build-distribution-local-jre.sh /Users/nchandra/.sdkman/candidates/java/current/zulu-8.jdk/Contents/Home/jre /tmp/steply-dist

------

Optional:
cp steply-cli/target/*-jar-with-dependencies.jar /private/tmp/steply-dist/lib/


PR: (Auto):
Then a new build triggers and "- name: Create GitHub Release" pushes/uploads this zip file.
"- name: Update install_no_jre.sh with latest release tag " will update the install_no_jre.sh.
```

# RUN UNIT TESTS
- Only tests the logic. 
- It doesn't test the actual installation of Java or unzip

```shell
bats scripts/tests/install_no_jre.bats
```
output looks like:
```shell
➜  steply git:(main) ✗ bats scripts/tests/install_no_jre.bats
install_no_jre.bats
 ✓ detect_os: returns 'debian' when apt-get is available
 ✓ detect_os: returns 'fedora' when dnf is available (no apt-get)
 ✓ detect_os: returns 'amazon-linux' when yum present and os-release has 'Amazon Linux 2'
 ✓ detect_os: returns 'fedora-yum' when yum present but not Amazon Linux
 ✓ detect_os: returns 'macos-brew' on Darwin when brew is available
 ✓ detect_os: returns 'macos-no-brew' on Darwin without brew
 ✓ detect_os: returns 'unknown' when no package manager and not Darwin
 ✓ get_java_major_version: returns 17 for OpenJDK 17
 ✓ get_java_major_version: returns 21 for OpenJDK 21
 ✓ get_java_major_version: returns 0 when java is not available
 ✓ ensure_java: exits 0 and skips install when Java 17 is present
 ✓ ensure_java: exits 0 and skips install when Java 21 is present
 ✓ ensure_java: calls install_java_debian on debian when java absent
 ✓ ensure_java: calls install_java_fedora on fedora when java absent
 ✓ ensure_java: calls install_java_amazon on amazon-linux when java absent
 ✓ ensure_java: calls install_java_brew on macos-brew when java absent
 ✓ ensure_java: exits 1 on macos-no-brew when java absent (prints error)
 ✓ ensure_java: exits 1 on unknown OS when java absent
 ✓ ensure_unzip: exits 0 and skips install when unzip is present
 ✓ ensure_unzip: calls install_unzip_debian on debian when unzip absent
 ✓ ensure_unzip: calls install_unzip_fedora on fedora when unzip absent
 ✓ ensure_unzip: calls install_unzip_yum on amazon-linux when unzip absent
 ✓ ensure_unzip: calls install_unzip_brew on macos-brew when unzip absent
 ✓ ensure_unzip: exits 1 on unknown OS when unzip absent
 ✓ setup_path: appends BIN_DIR to .bashrc when not already in PATH
 ✓ setup_path: appends BIN_DIR to .zshrc when not already in PATH
 ✓ setup_path: does not modify .bashrc when BIN_DIR already in PATH
 ✓ setup_path: does not append to .bashrc when BIN_DIR already listed in file

28 tests, 0 failures
```

RUN:
=====
➜  random pwd
/Users/nchandra/Downloads/STEPLY_WORKSPACE/random
steply --scenario example/hello_world_status_ok_assertions_new.json --target example/github_host_new.properties              

or:

➜  cd steply-dist
./bin/steply.sh --scenario example/hello_world_status_ok_assertions.json --target example/github_host.properties
(example folder comes with it)

```

# Steply — MVP

This repository contains an MVP implementation for the "Single Scenario CLI" described in issue #2.

Modules:
- steply-core: runner, config loader, report generator (MVP)
- steply-cli: CLI entrypoint (commons-cli)
- steply-distribution: assembly descriptor + scripts to build distribution zip

How to build locally:
1. Update zerocode version (optional) in the parent `pom.xml` property `zerocode.version`.
2. Run: `mvn -T1C clean package -DskipTests`

Distribution:
- There are two scripts in `scripts/`:
  - `build-distribution.sh` — download a Temurin macOS/AArch64 JRE and assemble distribution (automatic).
  - `build-distribution-local-jre.sh` — assemble distribution using a local JRE path you provide. (SEE BELOW HOW TO RUN)

See `scripts/README-distribution.md` for usage examples.

**************************************************
=> PREPARE THE CONTENT FOR ZIP FILE:
```shell
Quick one-off fix (if you want to test now without changing scripts)

Build the CLI jar: 
mvn -pl steply-cli -am package -DskipTests

Copy the jar into your distribution's lib manually: 
cp steply-cli/target/*-jar-with-dependencies.jar /private/tmp/steply-dist/lib/
```

=> BUILD THE ZIP FILE:
MAC:
```shell
./scripts/build-distribution-local-jre.sh /Users/nchandra/.sdkman/candidates/java/current/zulu-8.jdk/Contents/Home/jre /tmp/steply-dist
```

## AUTO PUBLISH RELEASE and AUTO UPDATE INSTALL SCRIPT:
- On every push ci.yml workflow runs, but it doesn't trigger the auto-upload release or auto update install.sh file
- So it ci.yml workflow run was Green, then create a tag and push it, then it triggers the auto-upload release 
- and create a PR to auto update install.sh file.
- Note: the zip file name becomes same as the TAG name. That's not a problem. But inside it may have old "VERSION.txt" which folds a different version.
- "./bin/steply.sh -v" : prints from the "VERSION.txt" file.
- So best practice will be to update the "VERSION.txt" file, then create a matching tag and push.
- Example:
  - Update "VERSION.txt" to "20260310.05"
  - Create a tag "20260310.05" and push it.
  - git tag 20260309.05
    git push origin 20260309.05
  - Then it triggers the auto-upload release and create a PR to update install.sh file with the new tag.
- (even if you can't match, there is no problem functional wise)

RUN:
```
steply --scenario example/hello_world_status_ok_assertions_new.json --target example/github_host_new.properties --reports ./target/reports
```

RUN THE TEST:
```shell
➜  steply-dist pwd
/private/tmp/steply-dist

Make sure bin/steply.sh is executable, then run:
cd /private/tmp/steply-dist

➜  steply-dist 
./bin/steply.sh --scenario example/github-get-test.json --target example/github.properties --reports ./target/reports

========================================
Steply Test Execution v0.1.0-SNAPSHOT
========================================
Scenario: example/github-get-test.json
Target: example/github.properties
Report: ./target/reports
========================================
Executing tests...

Total: 1
Passed: 1
Failed: 0
Duration: 0ms
========================================
Reports generated at: ./target/reports/steply-report
========================================
➜  steply-dist 
```

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ RUNNING @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

FROM PROJECT ROOT:
=> Using --scenario:
java -jar steply-cli/target/steply-cli-0.1.0-SNAPSHOT-jar-with-dependencies.jar
--scenario example/github-get-test.json
--target example/github.properties
--reports ./target/reports
--log-level INFO

=> Using -s :
java -jar steply-cli/target/steply-cli-0.1.0-SNAPSHOT-jar-with-dependencies.jar -s example/github-get-test.json -t example/github.properties -r ./target/reports -l INFO

=> Build Distribution zip:
./scripts/build-distribution-local-jre.sh /Users/<MYHOMEDIR>/.sdkman/candidates/java/current/zulu-8.jdk/Contents/Home/jre zip_folder


# STEPLY CLI
export PATH="/Users/nchandra/Downloads/STEPLY_WORKSPACE/steply-dist/bin:$PATH
(Not necessary if you're creating a Symlink to bin/steply.sh in your /usr/local/bin or similar)

DO THIS FOR SYMLINK:
```shell
sudo tee /usr/local/bin/steply > /dev/null <<'EOF'
#!/bin/bash
exec "/Users/nchandra/Downloads/STEPLY_WORKSPACE/steply-dist/bin/steply.sh" "$@"
EOF
sudo chmod +x /usr/local/bin/steply
```

REVIEW THE SYMLINK:
```
➜  ~ view /usr/local/bin/steply            
#!/bin/bash
exec "/Users/nchandra/Downloads/STEPLY_WORKSPACE/steply-dist/bin/steply.sh" "$@"
```

TEST THE SYMLINK:
Run it from anywhere, where you have the "example" folder available:
```
➜  ~ steply -h                        
Error parsing arguments: Missing required option: t
usage: steply
 -f,--folder <arg>    Folder containing multiple scenarios
 -h,--help         Show help
 -l,--log-level <arg>   Logging level (WARN/INFO/DEBUG)
 -r,--reports <arg>   Custom report output directory (default: ./target)
 -s,--scenario <arg>   Single scenario file path
 -t,--target <arg>    Target environment properties file
 -v,--version       Show version information

Running example:
----------------
➜  steply-dist pwd
/Users/nchandra/Downloads/STEPLY_WORKSPACE/steply-dist
➜  steply-dist 

➜  steply-dist steply --scenario example/github-get-test.json --target example/github.properties --reports ./target/reports
========================================
Steply Test Execution v0.1.0-SNAPSHOT
========================================
Scenario: example/github-get-test.json
Target: example/github.properties
Report: ./target/reports
========================================
Executing tests...

Total: 1
Passed: 1
Failed: 0
Duration: 0ms
========================================
Reports generated at: ./target/reports/steply-report
========================================
```

RUN FROM RANDOM FOLDER(TESTED):
```shell
➜  random_folder pwd
/Users/nchandra/Downloads/STEPLY_WORKSPACE/random_folder

➜  random_folder ls -l  
total 0
drwxr-xr-x  4 nchandra  staff  128 29 Dec 01:14 example

➜  random_folder steply --scenario example/github-get-test.json --target example/github.properties --reports ./target/reports
========================================
Steply Test Execution v0.1.0-SNAPSHOT
========================================
Scenario: example/github-get-test.json
Target: example/github.properties
Report: ./target/reports
========================================
Executing tests...

Total: 1
Passed: 1
Failed: 0
Duration: 0ms
========================================
Reports generated at: ./target/reports/steply-report
========================================
```
