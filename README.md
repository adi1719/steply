# Steply
Steply is a CLI tool to validate APIs, databases, Kafka messages, and more.

✨ Define the outcome, and Steply generates and executes the test automatically!

- Automate BDD-style tests or run manual validations using simple JSON or YAML — no coding required.
- Store tests in Git and easily manage manual tests, regression suites, and integration tests.

## AI Prompt (example)
### Generated Scenarios for `Claude Code` or CoPilot or similar:
> Write a Zerocode scenario that conforms to `schema/zerocode-scenario-schema.json` for `<your API testing idea>`.
> Use the `assertions` block (not `verify`) and include retry of 3 attempts with 500ms delay.

Two starter templates live under [`templates/`](templates/): `example_scenario_1.json` (typical REST flow with two steps), and `example_scenario_2.json` (parameterized scenario with both `valueSource` and `csvSource`).

See [examples](https://github.com/QABEES/steply-examples).

## Quick Start
Laptop or PC:
- Step-1: Install Steply (In your laptop or PC)
- Step-2: Clone the [examples](https://github.com/QABEES/steply-examples) repo and then do `cd steply-examples`
- Step-3: Run a test or test suite using the **run** command and verify the **PASS/FAIL** result at the concole.
  - Also see `/target` for reports & logs

CI CD:
- Step-1: Push your test scenarios and envs to your Git repo. Ignore the `/target` (results) folder in `.gitignore`.
- Step-2: Configure the CI workflow (see the **Install** section below).
- Step-3: Trigger the workflow and check the Job console for **PASS/FAIL** status at the console
  - Also see `/target` for reports & logs(or look for `Artifacts` after CI job completes)

## Install
### Mac Arm / Mac Intel / Linux / Ubuntu / VPS / CI CD Workflow
```shell
curl -fsSL https://raw.githubusercontent.com/QABEES/steply/main/scripts/install.sh | bash
```

<details>
<summary>Example Step ◀ (Click to expand)</summary>

Expects Java 17+ to be available on the PATH. If not found, the script will attempt to install it automatically.

**CI (GitHub Actions / GitLab Pipeline / Linux) — requires Java 17:**

Add the following steps to your CI workflow on Ubuntu/Linux.

_(This is a GitHub Actions step. A similar step can go into a GitLab CI/CD Pipeline or Jenkins job.)_
```yaml
- name: Set up Java 17
  uses: actions/setup-java@v4
  with:
    distribution: temurin
    java-version: '17'

- name: Install Steply
  run: |
    curl -fsSL https://raw.githubusercontent.com/QABEES/steply/main/scripts/install.sh | bash
    echo "$HOME/.local/bin" >> $GITHUB_PATH
```

</details>

### Windows OS
Follow the steps below

### Manual Install (Windows, Unix & Mac)

**Step 1 — Download the zip**
Go to the [Steply Releases](https://github.com/QABEES/steply/releases) page and download the `no-jre` zip for your target release, e.g.:
```
steply-20260425.01-no-jre.zip
```

**Step 2 — Unzip**
```shell
unzip steply-20260425.01-no-jre.zip -d ~/steply
```

**Step 3 — Ensure Java 17+ is available**
Check that `JAVA_HOME` points to a Java 17+ installation:
```shell
java -version          # must be 17 or higher
echo $JAVA_HOME        # should not be empty
```
If `JAVA_HOME` is not set, set it in your shell profile (e.g. `~/.zshrc` or `~/.bashrc`):
```shell
export JAVA_HOME=/path/to/your/java17
```

**Step 4 — Add Steply to PATH**
```shell
export PATH="$HOME/steply/bin:$PATH"
```
Add the same line to your shell profile so it persists across sessions, then reload:
```shell
source ~/.zshrc   # or source ~/.bashrc
```

**Step 5 — Verify**
```shell
steply --version
```

## Run a test
```shell
steply --scenario tests/get_user_api.json --target-env env/sit1.properties
```

## Run a full test suite
```shell
steply --suite tests --target-env env/sit.properties
```

# Project Folder Structure:
```
my-integration-testing-project/
├── env
│   ├── sit.properties
│   ├── uat.properties
│   ├── pre_prod.properties
│   └── github_host.properties
└── tests
   ├── validate_github_user_api.json
   ├── validate_create_user_api.json
   └── validate_update_emplyee_api.json
```

#### TEST RESULTS:
```
├── target/
│   ├── logs
│   │   └── executions.log
│   ├── test-report.csv
│   ├── test-interactive-report.html
```

## Testcase Example:

JSON
```json
  {
    "name": "call_pcdp_api",
    "url": "https://api.github.com/users/octocat",
    "method": "GET",
    "request": {
      "headers": {
        "Content-Type": "application/json"
      }
    },
    "verify": {
      "status": 200
    }
  }
```

or

YAML
```yaml
- name: call_pcdp_api
  url: https://api.github.com/users/octocat
  method: GET
  request:
    headers:
      Content-Type: application/json
  verify:
    status: 200
```

## Exit Codes (for CI Workflow)

Steply returns(for the example above):
- 0 → HTTP 200 OK
- Non-zero → Any other response

This makes it easy to use in CI pipelines to determine build status.

## Authentication
The Authorization header can be automatically populated using a token from an authentication server.


## CLI Help
```shell
➜  steply -h

or

➜  steply --help
```

## Reports & Logs
After execution, reports are generated in the "target/" folder:
- HTML interactive report
- CSV report
- Execution logs (see "target/logs/" folder)

## Notes
- `--folder` and `--suite` work the same way.
- `--target` and `--target-env` work the same way.
- Short forms like `--targ` are also accepted.

## Alternative to
- Postman
- Insomnia
- Karate
- PyRestTest
- Cucumber

but with modern, opensource, lightweight, secure and CLI appraoch, providing easily pluggable cloud integrations.

While the above tools are powerful, they are often heavy, proprietary, or tightly coupled to specific language ecosystems(such as Java, Groovy, Python etc).

This project :
- focuses on providing a open-source and collaborative developer/SDET experience
- provides easy/pluggable integrations (Kafka, S3, Postgres, and more)

## JSON Schema for Test Scenario
A JSON Schema (Draft-07) for scenario files is published at [`schema/zerocode-scenario-schema.json`](schema/zerocode-scenario-schema.json) and
pointed to from `robots.txt` at the project root. Use it to:

- **Validate scenarios from the CLI**, e.g. with `ajv-cli`:

  ```bash
  # Note: This is optional step, only do this if you have npx and ajv-cli already installed
  # npx: Runs npm package without global install
  npx ajv-cli validate -s schema/zerocode-scenario-schema.json -d core/src/test/resources/templates/example_scenario_1.json
  ```

## Credits
Special thanks to all the authors and contributors of the zerocode-tdd JSON/YAML testing framework.

## Uninstall
**macOS / Linux:**
```shell
curl -fsSL https://raw.githubusercontent.com/QABEES/steply/main/scripts/uninstall.sh | bash
```

This removes the `steply` launcher, all installed files, and the PATH entry from your shell profile.

## Documentation
For detailed documentation and examples, visit [here](https://zerocode-tdd.tddfy.com/)

As you are using the Steply CLI, you can ignore the Maven/Java sections in the documentation.
