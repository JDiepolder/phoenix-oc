# Phoenix-OC - Applied Optimal Control

This repository contains instructions to set up the environment for Phoenix-OC.

<img src="https://github.com/JDiepolder/test/blob/main/media/phoenix_ui.png?raw=true" alt="drawing" width="900"/>

> [!NOTE]  
> Phoenix-OC can run in your local environment, in the cloud, or on a compute cluster.
> 
> The instructions in this repository show a containerized setup including all dependencies to work with Phoenix-OC.

## What is Phoenix-OC?

Phoenix-OC is a general-purpose optimal control framework for modeling, discretizing, solving, and post-processing optimal control problems.

Among many others, Phoenix-OC includes the following features:

- **State Discretization**: Collocation methods (Hermite-Simpson, RadauIIA, Trapezoidal, Backward Euler, Forward Euler).
- **Control Parameterization**: B-Splines (arbitrary smoothness, control derivatives of arbitrary order).
- **Cost Function**: Including, but not limited to, end-point (Mayer) cost and integral (Lagrange) cost functions.
- **Constraint Functions**: Including, but not limited to, end-point constraint, path constraint, and integral constraint functions.  
- **Automatic Differentiation**: First- and second-order derivatives.
- **Parametric Problems**: Including post-optimal sensitivity analysis.
- **Bilevel Optimal Control**: Optimal control problems can depend on other optimal control problems.
- **Multi-Phase Problems**: Essentially arbitrary linkage conditions between phases.
- **Parallelization**: Parallel batch processing of parametrized optimal control problems.
- **Modeling and Post-Processing**: Integrated capabilities for problem definition, modeling, visualization, and export.

## How to get started?

The easiest way to get started is to use a Codespace. Simply click on the `Code` button on the right upper part of the main page of this repository. 

<img src="https://github.com/JDiepolder/test/blob/main/media/code_button_steps.png?raw=true" alt="drawing" width="400"/>

The first time a Codespace is created, the initial setup requires some minutes to complete. Thereafter, the Codespace will start within seconds. If you have trouble creating the Codespace, you can follow the instructions [here](https://docs.github.com/en/codespaces/developing-in-codespaces/creating-a-codespace-for-a-repository).

The startup check will report missing components in the environment after the initial setup.

You need to run the Phoenix install script to fully configure the environment. (If you wish to update the installed components later, you can simply re-run this script.)

Once the environment is set up, you should see the Phoenix extension (flame icon) on the left side.

**Initial Setup**:

After the environment is set up you need to add the Phoenix-OC app. 

<img src="https://github.com/JDiepolder/test/blob/main/media/get_started.gif?raw=true" alt="drawing" width="960"/>

**First Example**:

To get started you can explore the examples provided with Phoenix-OC. 

<img src="https://github.com/JDiepolder/test/blob/main/media/add_and_run_example.gif?raw=true" alt="drawing" width="960"/>

## Documentation

The documentation is embedded within the application. Each field in the configuration file has built-in markdown documentation. To view the documentation, simply hover over the respective field.

## Bug Reports

If you encounter a bug, please create an issue with a minimum working example. Ideally, include a self-contained configuration file that reproduces the bug.

## Feature Requests

If you have a feature request, please create an issue describing the requested feature. Ideally, include an example snippet illustrating how the feature should be made accessible in the user interface.

