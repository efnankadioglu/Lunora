# Lunora Recommendation Engine

Lunora günlük aktivite öneri motorunun çalışma mantığını tanımlar.

Bu doküman algoritmanın nasıl çalışacağını açıklar.

Astrolojik puanların ve gökyüzü kurallarının gerçek kaynağı:

`Docs/JSONDatas/astroRules.json`

Aktivite kataloğunun gerçek kaynağı:

`Docs/JSONDatas/activities.json`

---

# 1. Temel Mimari

Recommendation Engine iki ayrı veri kaynağını birleştirir:

1. Activity Catalog
2. Astro Rules

Activity Catalog bir aktivitenin ne olduğunu tanımlar.

Astro Rules güncel gökyüzünün hangi davranışları ve yaşam alanlarını desteklediğini veya zorlaştırdığını tanımlar.

Recommendation Engine bu iki veri kaynağını eşleştirerek kullanıcıya o gün için uygun aktiviteleri seçer.

Akış:

Günün gökyüzü
↓
Astro Rules
↓
Günlük enerji skorları
↓
Activity Catalog
↓
Filtreleme
↓
Puanlama
↓
Sıralama
↓
Bugün için öneriler

Astrolojik motor kendi başına yeni aktivite üretmez.

Yalnızca mevcut activity datasetindeki aktiviteleri değerlendirir.

---

# 2. Activity Dataset Schema

Her aktivite aşağıdaki temel alanları içerir:

- `id`
- `title`
- `short_description`
- `topics[]`
- `actions[]`
- `context[]`
- `intensity`
- `relationship_modes[]`

Örnek:

```json
{
  "id": "research_topic_of_interest",
  "title": "Merak ettiğin bir konuda mini araştırma yap",
  "short_description": "Aklını kurcalayan tek bir konu seçip kısa bir araştırma yap.",
  "topics": [
    "learning"
  ],
  "actions": [
    "research"
  ],
  "context": [],
  "intensity": "low",
  "relationship_modes": []
}
