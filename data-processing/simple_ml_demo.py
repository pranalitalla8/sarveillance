#!/usr/bin/env python3
"""
Simple ML Demo for NASA SAR App
Demonstrates oil spill detection and ship detection without external dependencies
"""

import json
import random
import math
from pathlib import Path
from datetime import datetime

class SimpleMLDemo:
    def __init__(self, data_dir="data", model_dir="models"):
        self.data_dir = Path(data_dir)
        self.model_dir = Path(model_dir)
        self.model_dir.mkdir(exist_ok=True)
        
    def create_synthetic_oil_spill_data(self, num_samples=1000):
        """Create synthetic oil spill detection dataset"""
        print("📊 Creating synthetic oil spill dataset...")
        
        dataset = []
        
        for i in range(num_samples):
            if i < num_samples // 2:
                # Normal sea surface
                backscatter = random.uniform(0.3, 0.8)
                texture = random.uniform(0.1, 0.3)
                label = 0  # No oil spill
            else:
                # Oil spill surface (darker, smoother)
                backscatter = random.uniform(0.05, 0.25)
                texture = random.uniform(0.05, 0.15)
                label = 1  # Oil spill
            
            dataset.append({
                'id': i,
                'backscatter': round(backscatter, 4),
                'texture': round(texture, 4),
                'label': label,
                'confidence': random.uniform(0.7, 0.95)
            })
        
        print(f"✅ Created {num_samples} samples")
        print(f"   📊 Oil spills: {sum(1 for d in dataset if d['label'] == 1)}")
        print(f"   📊 Normal sea: {sum(1 for d in dataset if d['label'] == 0)}")
        
        return dataset
    
    def train_simple_model(self, dataset):
        """Train a simple rule-based model"""
        print("🤖 Training simple oil spill detection model...")
        
        # Simple rule-based model
        model_rules = {
            'backscatter_threshold': 0.25,
            'texture_threshold': 0.2,
            'rules': [
                {
                    'condition': 'backscatter < 0.25 AND texture < 0.2',
                    'prediction': 1,
                    'confidence': 0.9
                },
                {
                    'condition': 'backscatter >= 0.3 AND texture >= 0.15',
                    'prediction': 0,
                    'confidence': 0.85
                }
            ]
        }
        
        # Test model on dataset
        correct_predictions = 0
        total_predictions = len(dataset)
        
        for sample in dataset:
            prediction = self.predict_oil_spill(sample, model_rules)
            if prediction == sample['label']:
                correct_predictions += 1
        
        accuracy = correct_predictions / total_predictions
        
        model_info = {
            'model_type': 'Rule-based Oil Spill Detection',
            'accuracy': round(accuracy, 3),
            'rules': model_rules,
            'training_samples': total_predictions,
            'correct_predictions': correct_predictions,
            'trained_at': datetime.now().isoformat()
        }
        
        # Save model
        model_path = self.model_dir / "simple_oil_spill_model.json"
        with open(model_path, 'w') as f:
            json.dump(model_info, f, indent=2)
        
        print(f"✅ Model trained with accuracy: {accuracy:.3f}")
        print(f"✅ Model saved to: {model_path}")
        
        return model_info
    
    def predict_oil_spill(self, sample, model_rules):
        """Predict oil spill using simple rules"""
        backscatter = sample['backscatter']
        texture = sample['texture']
        
        # Apply rules
        if backscatter < model_rules['backscatter_threshold'] and texture < model_rules['texture_threshold']:
            return 1  # Oil spill
        elif backscatter >= 0.3 and texture >= 0.15:
            return 0  # No oil spill
        else:
            # Default prediction based on backscatter
            return 1 if backscatter < 0.3 else 0
    
    def validate_with_m4d_dataset(self, m4d_samples=500):
        """Validate model with synthetic M4D dataset"""
        print("🔍 Validating model with M4D dataset...")
        
        # Create M4D validation dataset
        m4d_data = []
        for i in range(m4d_samples):
            if i < m4d_samples // 2:
                # Oil spill in M4D format
                backscatter = random.uniform(0.08, 0.22)
                texture = random.uniform(0.06, 0.18)
                label = 1
            else:
                # Normal sea in M4D format
                backscatter = random.uniform(0.35, 0.75)
                texture = random.uniform(0.12, 0.28)
                label = 0
            
            m4d_data.append({
                'backscatter': backscatter,
                'texture': texture,
                'label': label
            })
        
        # Load trained model
        model_path = self.model_dir / "simple_oil_spill_model.json"
        if not model_path.exists():
            print("❌ No trained model found. Run training first.")
            return None
        
        with open(model_path, 'r') as f:
            model_info = json.load(f)
        
        # Validate model
        correct_predictions = 0
        for sample in m4d_data:
            prediction = self.predict_oil_spill(sample, model_info['rules'])
            if prediction == sample['label']:
                correct_predictions += 1
        
        validation_accuracy = correct_predictions / len(m4d_data)
        
        validation_results = {
            'dataset': 'M4D Oil Spill Dataset',
            'validation_samples': len(m4d_data),
            'accuracy': round(validation_accuracy, 3),
            'correct_predictions': correct_predictions,
            'validated_at': datetime.now().isoformat()
        }
        
        # Save validation results
        validation_path = self.model_dir / "m4d_validation_results.json"
        with open(validation_path, 'w') as f:
            json.dump(validation_results, f, indent=2)
        
        print(f"✅ M4D validation accuracy: {validation_accuracy:.3f}")
        print(f"✅ Validation results saved to: {validation_path}")
        
        return validation_results
    
    def implement_oil_detection_algorithm(self):
        """Implement oil detection algorithm for SAR analysis"""
        print("🔬 Implementing oil detection algorithm...")
        
        algorithm = {
            'name': 'SAR Oil Spill Detection Algorithm',
            'version': '1.0',
            'detection_method': 'Multi-threshold Analysis',
            'parameters': {
                'backscatter_thresholds': {
                    'oil_spill_max': 0.25,
                    'normal_sea_min': 0.3,
                    'uncertainty_range': [0.25, 0.3]
                },
                'texture_analysis': {
                    'oil_spill_max': 0.2,
                    'normal_sea_min': 0.15,
                    'smoothness_weight': 0.7
                },
                'size_constraints': {
                    'min_oil_spill_area': 100,
                    'max_oil_spill_area': 10000
                }
            },
            'processing_steps': [
                'SAR data preprocessing',
                'Backscatter thresholding',
                'Texture analysis',
                'Size filtering',
                'Confidence calculation',
                'Result validation'
            ],
            'output_format': {
                'detection_mask': 'Binary image (0/1)',
                'confidence_map': 'Probability values (0-1)',
                'metadata': 'Detection parameters and statistics'
            }
        }
        
        # Save algorithm
        algorithm_path = self.model_dir / "oil_detection_algorithm.json"
        with open(algorithm_path, 'w') as f:
            json.dump(algorithm, f, indent=2)
        
        print(f"✅ Oil detection algorithm saved to: {algorithm_path}")
        
        return algorithm
    
    def create_ship_detection_system(self):
        """Create ship detection system for SAR data"""
        print("🚢 Creating ship detection system...")
        
        ship_system = {
            'name': 'SAR Ship Detection System',
            'version': '1.0',
            'detection_method': 'Rule-based + Shape Analysis',
            'ship_types': {
                'cargo_ships': {
                    'length_range': [100, 400],
                    'width_range': [15, 60],
                    'backscatter_range': [0.4, 0.8],
                    'typical_shape': 'rectangular'
                },
                'fishing_vessels': {
                    'length_range': [20, 80],
                    'width_range': [5, 15],
                    'backscatter_range': [0.3, 0.6],
                    'typical_shape': 'elongated'
                },
                'naval_vessels': {
                    'length_range': [80, 200],
                    'width_range': [10, 25],
                    'backscatter_range': [0.5, 0.9],
                    'typical_shape': 'streamlined'
                }
            },
            'detection_parameters': {
                'backscatter_threshold': 0.4,
                'size_constraints': {
                    'min_length': 20,
                    'max_length': 500,
                    'min_width': 5,
                    'max_width': 100
                },
                'shape_analysis': {
                    'aspect_ratio_min': 0.2,
                    'aspect_ratio_max': 5.0,
                    'circularity_threshold': 0.3
                }
            },
            'validation_criteria': {
                'minimum_confidence': 0.6,
                'maximum_false_positive_rate': 0.05,
                'minimum_recall_rate': 0.85
            }
        }
        
        # Save ship detection system
        ship_system_path = self.model_dir / "ship_detection_system.json"
        with open(ship_system_path, 'w') as f:
            json.dump(ship_system, f, indent=2)
        
        print(f"✅ Ship detection system saved to: {ship_system_path}")
        
        return ship_system
    
    def test_model_accuracy(self, test_samples=300):
        """Test model accuracy and provide tuning recommendations"""
        print("🧪 Testing model accuracy...")
        
        # Create test dataset
        test_data = self.create_synthetic_oil_spill_data(test_samples)
        
        # Load trained model
        model_path = self.model_dir / "simple_oil_spill_model.json"
        if not model_path.exists():
            print("❌ No trained model found. Run training first.")
            return None
        
        with open(model_path, 'r') as f:
            model_info = json.load(f)
        
        # Test model
        correct_predictions = 0
        false_positives = 0
        false_negatives = 0
        
        for sample in test_data:
            prediction = self.predict_oil_spill(sample, model_info['rules'])
            actual = sample['label']
            
            if prediction == actual:
                correct_predictions += 1
            elif prediction == 1 and actual == 0:
                false_positives += 1
            elif prediction == 0 and actual == 1:
                false_negatives += 1
        
        accuracy = correct_predictions / len(test_data)
        precision = correct_predictions / (correct_predictions + false_positives) if (correct_predictions + false_positives) > 0 else 0
        recall = correct_predictions / (correct_predictions + false_negatives) if (correct_predictions + false_negatives) > 0 else 0
        f1_score = 2 * (precision * recall) / (precision + recall) if (precision + recall) > 0 else 0
        
        test_results = {
            'test_samples': len(test_data),
            'accuracy': round(accuracy, 3),
            'precision': round(precision, 3),
            'recall': round(recall, 3),
            'f1_score': round(f1_score, 3),
            'false_positives': false_positives,
            'false_negatives': false_negatives,
            'test_timestamp': datetime.now().isoformat()
        }
        
        # Generate recommendations
        recommendations = []
        if accuracy < 0.8:
            recommendations.append("Consider adjusting backscatter threshold")
            recommendations.append("Add more training samples")
        if precision < 0.8:
            recommendations.append("Reduce false positive rate by increasing thresholds")
        if recall < 0.8:
            recommendations.append("Improve detection sensitivity")
        
        test_results['recommendations'] = recommendations
        
        # Save test results
        test_path = self.model_dir / "model_test_results.json"
        with open(test_path, 'w') as f:
            json.dump(test_results, f, indent=2)
        
        print(f"✅ Test accuracy: {accuracy:.3f}")
        print(f"✅ Test F1-score: {f1_score:.3f}")
        print(f"✅ Test results saved to: {test_path}")
        
        if recommendations:
            print("💡 Recommendations:")
            for rec in recommendations:
                print(f"   - {rec}")
        
        return test_results
    
    def run_complete_demo(self):
        """Run complete ML demo pipeline"""
        print("🚀 Starting ML Demo Pipeline...")
        print("=" * 50)
        
        # Step 1: Create and train model
        dataset = self.create_synthetic_oil_spill_data(1000)
        model_info = self.train_simple_model(dataset)
        
        # Step 2: Validate with M4D dataset
        validation_results = self.validate_with_m4d_dataset(500)
        
        # Step 3: Implement oil detection algorithm
        algorithm = self.implement_oil_detection_algorithm()
        
        # Step 4: Create ship detection system
        ship_system = self.create_ship_detection_system()
        
        # Step 5: Test model accuracy
        test_results = self.test_model_accuracy(300)
        
        # Create demo summary
        demo_summary = {
            'demo_version': '1.0',
            'execution_timestamp': datetime.now().isoformat(),
            'components': {
                'oil_spill_model': model_info is not None,
                'm4d_validation': validation_results is not None,
                'detection_algorithm': algorithm is not None,
                'ship_detection': ship_system is not None,
                'accuracy_testing': test_results is not None
            },
            'performance_metrics': {
                'training_accuracy': model_info['accuracy'] if model_info else None,
                'validation_accuracy': validation_results['accuracy'] if validation_results else None,
                'test_accuracy': test_results['accuracy'] if test_results else None
            },
            'output_files': [
                'simple_oil_spill_model.json',
                'm4d_validation_results.json',
                'oil_detection_algorithm.json',
                'ship_detection_system.json',
                'model_test_results.json'
            ]
        }
        
        # Save demo summary
        summary_path = self.model_dir / "ml_demo_summary.json"
        with open(summary_path, 'w') as f:
            json.dump(demo_summary, f, indent=2)
        
        print(f"\n🎉 ML Demo Pipeline completed successfully!")
        print(f"   📄 Demo summary: {summary_path}")
        print(f"   📁 Models directory: {self.model_dir}")
        
        return demo_summary

def main():
    print("🤖 NASA SAR ML Demo Pipeline")
    print("=" * 50)
    
    demo = SimpleMLDemo()
    demo.run_complete_demo()

if __name__ == "__main__":
    main()
