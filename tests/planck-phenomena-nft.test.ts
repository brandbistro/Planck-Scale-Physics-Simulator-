import { describe, it, expect, beforeEach } from 'vitest';

// Simulated contract state
let lastPhenomenonId = 0;
const phenomenonData = new Map();
const phenomenonOwners = new Map();

// Simulated contract functions
function mintPhenomenon(name: string, description: string, properties: Array<{key: string, value: string}>, discoverer: string) {
  const phenomenonId = ++lastPhenomenonId;
  phenomenonData.set(phenomenonId, {
    discoverer,
    name,
    description,
    properties
  });
  phenomenonOwners.set(phenomenonId, discoverer);
  return phenomenonId;
}

function transferPhenomenon(phenomenonId: number, sender: string, recipient: string) {
  if (phenomenonOwners.get(phenomenonId) !== sender) throw new Error('Not authorized');
  phenomenonOwners.set(phenomenonId, recipient);
  return true;
}

describe('Planck Phenomena NFT Contract', () => {
  beforeEach(() => {
    lastPhenomenonId = 0;
    phenomenonData.clear();
    phenomenonOwners.clear();
  });
  
  it('should mint a new Planck phenomenon NFT', () => {
    const id = mintPhenomenon('Quantum Foam Bubble', 'A localized fluctuation in the quantum foam', [
      { key: 'size', value: '1e-35 m' },
      { key: 'duration', value: '1e-43 s' }
    ], 'discoverer1');
    expect(id).toBe(1);
    const phenomenon = phenomenonData.get(id);
    expect(phenomenon.name).toBe('Quantum Foam Bubble');
    expect(phenomenon.properties.length).toBe(2);
    expect(phenomenonOwners.get(id)).toBe('discoverer1');
  });
  
  it('should transfer phenomenon ownership', () => {
    const id = mintPhenomenon('Planck Star', 'A hypothetical star with Planck-scale density', [
      { key: 'mass', value: '1e-8 kg' },
      { key: 'radius', value: '1e-35 m' }
    ], 'discoverer2');
    expect(transferPhenomenon(id, 'discoverer2', 'newowner1')).toBe(true);
    expect(phenomenonOwners.get(id)).toBe('newowner1');
  });
  
  it('should not allow unauthorized transfers', () => {
    const id = mintPhenomenon('Micro Black Hole', 'A black hole with Planck-scale event horizon', [
      { key: 'mass', value: '2.17645e-8 kg' },
      { key: 'lifetime', value: '1e-40 s' }
    ], 'discoverer3');
    expect(() => transferPhenomenon(id, 'unauthorized_user', 'newowner2')).toThrow('Not authorized');
  });
});

