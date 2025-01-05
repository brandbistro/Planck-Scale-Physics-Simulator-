import { describe, it, expect, beforeEach } from 'vitest';

// Simulated contract state
let simulationCount = 0;
const simulations = new Map();

// Simulated contract functions
function createSimulation(parameters: string, resourceAllocation: number, creator: string) {
  const simulationId = ++simulationCount;
  simulations.set(simulationId, {
    creator,
    parameters,
    resourceAllocation,
    status: 'pending',
    results: null
  });
  return simulationId;
}

function startSimulation(simulationId: number, sender: string) {
  const simulation = simulations.get(simulationId);
  if (!simulation) throw new Error('Invalid simulation');
  if (simulation.creator !== sender) throw new Error('Not authorized');
  if (simulation.resourceAllocation > 1000) throw new Error('Insufficient resources');
  simulation.status = 'running';
  simulations.set(simulationId, simulation);
  return true;
}

function updateSimulationResults(simulationId: number, results: string, sender: string) {
  if (sender !== 'CONTRACT_OWNER') throw new Error('Not authorized');
  const simulation = simulations.get(simulationId);
  if (!simulation) throw new Error('Invalid simulation');
  simulation.status = 'completed';
  simulation.results = results;
  simulations.set(simulationId, simulation);
  return true;
}

describe('Simulation Management Contract', () => {
  beforeEach(() => {
    simulationCount = 0;
    simulations.clear();
  });
  
  it('should create a new simulation', () => {
    const id = createSimulation('{"particles": 1000, "iterations": 1000000}', 500, 'user1');
    expect(id).toBe(1);
    const simulation = simulations.get(id);
    expect(simulation.parameters).toBe('{"particles": 1000, "iterations": 1000000}');
    expect(simulation.status).toBe('pending');
  });
  
  it('should start a simulation', () => {
    const id = createSimulation('{"particles": 500, "iterations": 500000}', 250, 'user2');
    expect(startSimulation(id, 'user2')).toBe(true);
    const simulation = simulations.get(id);
    expect(simulation.status).toBe('running');
  });
  
  it('should update simulation results', () => {
    const id = createSimulation('{"particles": 200, "iterations": 200000}', 100, 'user3');
    startSimulation(id, 'user3');
    expect(updateSimulationResults(id, '{"energy": 1e-35, "time": 1e-43}', 'CONTRACT_OWNER')).toBe(true);
    const simulation = simulations.get(id);
    expect(simulation.status).toBe('completed');
    expect(simulation.results).toBe('{"energy": 1e-35, "time": 1e-43}');
  });
  
  it('should not allow unauthorized simulation starts', () => {
    const id = createSimulation('{"particles": 300, "iterations": 300000}', 150, 'user4');
    expect(() => startSimulation(id, 'unauthorized_user')).toThrow('Not authorized');
  });
  
  it('should not allow simulations with insufficient resources', () => {
    const id = createSimulation('{"particles": 2000, "iterations": 2000000}', 1001, 'user5');
    expect(() => startSimulation(id, 'user5')).toThrow('Insufficient resources');
  });
  
  it('should not allow unauthorized result updates', () => {
    const id = createSimulation('{"particles": 400, "iterations": 400000}', 200, 'user6');
    startSimulation(id, 'user6');
    expect(() => updateSimulationResults(id, '{"energy": 2e-35, "time": 2e-43}', 'unauthorized_user')).toThrow('Not authorized');
  });
});

