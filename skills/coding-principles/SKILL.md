---
name: coding-principles
description: Practical guidance for applying KISS, DRY, SOLID, and YAGNI when designing or changing software.
license: MIT
---

# Coding Principles

Use these principles to make code easier to understand and change. Apply judgment: they are guides, not reasons to add abstractions or rewrite working code.

## KISS: Keep It Simple

- Prefer the most direct, readable solution that satisfies the request.
- Minimize concepts, indirection, dependencies, and state.
- Avoid cleverness and abstraction when ordinary control flow is clearer.

## DRY: Don't Repeat Yourself

- Keep a single source of truth for business rules and behavior that must stay consistent.
- Consolidate duplication when it represents the same knowledge and the abstraction makes future changes clearer.
- Small amounts of similar code are acceptable when sharing it would couple unrelated behavior or make the code harder to follow.

## SOLID

- **Single Responsibility:** Give a module or function one cohesive responsibility and one primary reason to change. Do not split code into tiny pieces without a clarity benefit.
- **Open/Closed:** Extend behavior through existing seams when a real variation exists. Do not build extension frameworks for hypothetical needs.
- **Liskov Substitution:** Keep implementations compatible with the promises and behavior of their base type or interface.
- **Interface Segregation:** Give consumers small interfaces containing only the operations they need.
- **Dependency Inversion:** Put abstractions at boundaries where they decouple important policy from volatile details, such as external services. Do not create interfaces for every helper or function.

## YAGNI: You Aren't Gonna Need It

- Implement what the current requirements need.
- Avoid speculative features, parameters, configuration, compatibility layers, and extension points.
- Add flexibility when a concrete requirement or repeated use demonstrates its value.

## Applying the Principles

1. Identify the requested behavior and its constraints.
2. Choose the smallest design that keeps related rules clear and consistent.
3. Add an abstraction only when it removes meaningful duplication or decouples a real change boundary.
4. Revisit the design if it becomes harder to understand than the problem it solves.
