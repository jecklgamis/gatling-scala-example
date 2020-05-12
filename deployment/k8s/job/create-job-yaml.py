#!/usr/bin/env python3

import argparse
import os

from jinja2 import Template


def write_job_file(template, output, java_opts, simulation_name):
    template = Template(open(template, 'rt').read())
    content = template.render(java_opts=java_opts, simulation_name=simulation_name)
    open(output, 'wt').write(content)
    print(f"Wrote {os.path.abspath(output)} with content \n{content}")


def parse_args():
    parser = argparse.ArgumentParser(description='Run Gatling simulation')
    parser.add_argument('--java_opts',
                        default='-Dbaseurl=http://localhost:8080 -DrequestPerSecond=10 -DdurationMin=0.25',
                        help='Java opts')
    parser.add_argument('--simulation',
                        default="gatling.test.example.simulation.ExampleGetSimulation",
                        help='Simulation name')
    return parser.parse_args()


args = parse_args()
print(f"Using java_opts = {args.java_opts}")
print(f"Using simulation = {args.simulation}")

write_job_file('job-template.yaml', "job.yaml", args.java_opts, args.simulation)
