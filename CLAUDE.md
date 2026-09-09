# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Gatling performance testing project written in Scala. Contains load test simulations that can be run via Maven plugin, executable JAR, Docker container, or Kubernetes Job.

## Build Commands

```bash
# Build executable JAR (creates target/gatling-scala-example.jar)
./mvnw clean package

# Build and create Docker image
make all

# Clean build artifacts
./mvnw clean
```

## Running Simulations

**Via Maven Plugin (perf-test profile):**
```bash
# Run default simulation (ExampleSimulation)
mvn test -Pperf-test

# Run specific simulation
mvn test -Pperf-test -DsimulationClass=gatling.test.example.simulation.ExampleGetSimulation
```

**Via Executable JAR:**
```bash
java -cp target/gatling-scala-example.jar io.gatling.app.Gatling -s gatling.test.example.simulation.ExampleSimulation
```

**Via Docker:**
```bash
docker run -e "JAVA_OPTS=-DbaseUrl=http://localhost:8080" \
  -e SIMULATION_NAME=gatling.test.example.simulation.ExampleGetSimulation gatling-scala-example:latest
```

**Via Kubernetes (Helm):**
```bash
./run-simulation-using-kubernetes.sh
```

**Via gatling-server (remote submission, no local JVM):**
```bash
curl -H "Authorization: Bearer ${API_TOKEN}" \
  -F "file=@target/gatling-scala-example.jar" \
  -F "simulation=gatling.test.example.simulation.ExampleSimulation" \
  -F "javaOpts=-DbaseUrl=http://localhost:8080 -DdurationMin=1 -DrequestPerSecond=10" \
  http://localhost:58080/task/upload
```
See [gatling-server](https://github.com/jecklgamis/gatling-server) for setup and the full API.

**Via gatling-mcp-server (AI agent, natural language):**
This repo has a project-scoped `.mcp.json` connecting to
[gatling-mcp-server](https://github.com/jecklgamis/gatling-mcp-server) - an MCP-capable AI client can upload the
jar and submit/monitor a run just by describing what you want, instead of the `curl` above.

## Convenience Scripts

| Script | Description |
|--------|-------------|
| `run-simulation-using-plugin.sh` | Run via Maven Gatling plugin |
| `run-simulation-using-jar.sh` | Run via executable JAR |
| `run-simulation-using-docker.sh` | Run via Docker container |
| `run-simulation-using-kubernetes.sh` | Run as Kubernetes Job via Helm |

## Test Configuration

All simulations use `PerfTestConfig` which reads values from system properties with defaults:

| Property | Default | Description |
|----------|---------|-------------|
| baseUrl | http://localhost:8080 | Target URL |
| requestPerSecond | 10 | Load rate |
| durationMin | 0.25 | Test duration in minutes |
| meanResponseTimeMs | 500 | Mean response time threshold |
| maxResponseTimeMs | 2000 | Max response time threshold |
| p95ResponseTimeMs | 250 | 95th percentile threshold |

Pass via `-D` flags: `mvn test -Pperf-test -DbaseUrl=http://example.com -DrequestPerSecond=50`

## Architecture

Simulations extend `io.gatling.core.Predef.Simulation` and are located in `src/main/scala/gatling/test/example/simulation/`:

- **ExampleSimulation** - POST request simulation (default)
- **ExampleGetSimulation** - GET request simulation
- **ExamplePostSimulation** - POST with JSON body
- **SingleFileExampleSimulation** - Self-contained example
- **PerfTestConfig** - Centralized configuration using SystemPropertiesUtil
- **SystemPropertiesUtil** - Helper for reading typed system properties

## Example Test App

A minimal Node.js HTTP server is provided for local testing:
```bash
cd example-app && node http-server.js 8080
```

## Test Results

HTML reports are generated in `target/results/` after each simulation run.
