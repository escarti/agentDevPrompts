# Metrics Feature Research

## Technical Context

**Existing Implementation:**
- Current telemetry: src/services/telemetry.ts
- Database schema: postgres with metrics_events table
- Export formats needed: CSV, JSON, PDF

## Integration Points

**Database Layer:**
- Use existing MetricsRepository (src/repositories/metrics.ts)
- Add new query methods for date range filtering
- Schema already supports custom dimensions

**API Layer:**
- RESTful endpoint: GET /api/v1/metrics/export
- Authentication: JWT bearer tokens required
- Rate limiting: 100 requests/hour per user

**Frontend:**
- React components in src/components/metrics/
- Use existing ChartJS integration
- Material-UI for export modal

## Key Decisions

**Export Formats:**
- CSV: Use fast-csv library (already in package.json)
- JSON: Native JSON.stringify with streaming for large datasets
- PDF: pdfkit library (need to add dependency)

**Performance:**
- Stream large exports (>1000 rows)
- Background job for PDF generation (use existing queue)
- Implement cursor-based pagination

## Dependencies

**New:**
- pdfkit@^0.14.0
- @types/pdfkit@^0.13.0

**Existing:**
- fast-csv (already installed)
- bull (queue system)
